import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_coffee_service.dart';
import '../services/firestore_order_service.dart';
import '../models/coffee_model.dart';

class CoffeeProvider with ChangeNotifier {
  final FirestoreCoffeeService _coffeeService = FirestoreCoffeeService();
  final FirestoreOrderService _orderService = FirestoreOrderService();
  List<Coffee> _coffees = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String _error = '';
  StreamSubscription? _coffeeSubscription;

  // مفاتيح التخزين المحلي
  static const String _ordersKey = 'coffee_shop_orders';
  static const String _favoritesKey = 'coffee_shop_favorites';

  List<Coffee> get coffees => _coffees;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  // الحصول على القهوة المفضلة
  List<Coffee> get favorites =>
      _coffees.where((coffee) => coffee.isFavorite).toList();

  CoffeeProvider() {
    _loadOrders();
    _listenToCoffees();
  }

  void _listenToCoffees() {
    _coffeeSubscription?.cancel();
    _isLoading = true;
    _coffeeSubscription = _coffeeService.getCoffeesStream().listen(
      (coffeesList) async {
        _coffees = coffeesList;
        await _loadFavorites();
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (error) {
        print('Stream Error: $error');
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadCoffees() async {
    // Only show loading indicator if list is empty for a faster feel
    if (_coffees.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _error = '';

    try {
      _coffees = await _coffeeService.getCoffees();
      // بعد تحميل القهوة، نقوم بتحميل المفضلة
      await _loadFavorites();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCoffees() async {
    await loadCoffees();
  }

  // Add method to update a coffee
  Future<bool> updateCoffee(String id, Coffee updatedCoffee) async {
    try {
      final success = await _coffeeService.updateCoffee(id, updatedCoffee);
      if (!success) {
        _error = 'Failed to update coffee';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add method to delete a coffee
  Future<bool> deleteCoffee(String id) async {
    try {
      final success = await _coffeeService.deleteCoffee(id);
      if (!success) {
        _error = 'Failed to delete coffee';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Coffee getCoffeeById(String id) {
    return _coffees.firstWhere(
      (coffee) => coffee.id == id,
      orElse: () => Coffee(
        id: '',
        name: 'Not Found',
        description: '',
        price: 0,
        imageUrl: '',
        rating: 0,
        reviewCount: 0,
        category: '',
        isFavorite: false,
      ),
    );
  }

  List<Coffee> getCoffeesByCategory(String category) {
    if (category == 'All Coffee') return _coffees;
    return _coffees.where((coffee) => coffee.category == category).toList();
  }

  // ========== المفضلة ==========

  // تبديل حالة المفضلة
  void toggleFavorite(String coffeeId) {
    final index = _coffees.indexWhere((coffee) => coffee.id == coffeeId);
    if (index != -1) {
      _coffees[index].isFavorite = !_coffees[index].isFavorite;
      _saveFavorites();
      notifyListeners();
    }
  }

  // التحقق إذا كانت القهوة مفضلة
  bool isFavorite(String coffeeId) {
    final coffee = _coffees.firstWhere(
      (c) => c.id == coffeeId,
      orElse: () => Coffee(
        id: '',
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
        rating: 0,
        reviewCount: 0,
        category: '',
        isFavorite: false,
      ),
    );
    return coffee.isFavorite;
  }

  // حفظ المفضلة في SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds =
          _coffees.where((c) => c.isFavorite).map((c) => c.id).toList();
      await prefs.setStringList(_favoritesKey, favoriteIds);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // تحميل المفضلة من SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];

      // تحديث حالة المفضلة للقهوة
      for (var coffee in _coffees) {
        coffee.isFavorite = favoriteIds.contains(coffee.id);
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // مسح جميع المفضلة
  Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);

      // إزالة المفضلة من جميع القهوة
      for (var coffee in _coffees) {
        coffee.isFavorite = false;
      }
      notifyListeners();
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // ========== الطلبات ==========

  // إضافة طلب جديد
  Future<void> addOrder(Order order) async {
    final addedOrder = await _orderService.addOrder(order);
    if (addedOrder != null) {
      _orders.insert(0, addedOrder);
      notifyListeners();
    }
  }

  // حذف طلب
  Future<void> removeOrder(String orderId) async {
    final success = await _orderService.deleteOrder(orderId);
    if (success) {
      _orders.removeWhere((order) => order.id == orderId);
      notifyListeners();
    }
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final success = await _orderService.updateOrderStatus(orderId, newStatus);
    if (success) {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = Order(
          id: _orders[index].id,
          coffeeName: _orders[index].coffeeName,
          coffeeImage: _orders[index].coffeeImage,
          price: _orders[index].price,
          quantity: _orders[index].quantity,
          size: _orders[index].size,
          isDairyFree: _orders[index].isDairyFree,
          orderDate: _orders[index].orderDate,
          status: newStatus,
        );
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    }
  }

  // الحصول على عدد الطلبات
  int get ordersCount => _orders.length;

  // الحصول على إجمالي المبيعات
  double get totalSales {
    return _orders.fold(
        0.0, (sum, order) => sum + (order.price * order.quantity));
  }

  // تصفية الطلبات حسب الحالة
  List<Order> getOrdersByStatus(String status) {
    return _orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // الحصول على الطلبات النشطة (ليست ملغاة أو منتهية)
  List<Order> get activeOrders {
    return _orders
        .where((order) =>
            order.status.toLowerCase() != 'cancelled' &&
            order.status.toLowerCase() != 'completed')
        .toList();
  }

  // إنشاء طلب جديد من بيانات القهوة
  Order createOrder({
    required Coffee coffee,
    required String size,
    required int quantity,
    required bool isDairyFree,
  }) {
    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coffeeName: coffee.name,
      coffeeImage: coffee.imageUrl,
      price: coffee.price,
      quantity: quantity,
      size: size,
      isDairyFree: isDairyFree,
      orderDate: DateTime.now(),
      status: 'Processing',
    );
  }

  // تحميل الطلبات من Firestore
  Future<void> _loadOrders() async {
    try {
      _orders = await _orderService.getOrders();
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  // مسح جميع الطلبات
  Future<void> clearAllOrders() async {
    for (var order in List.from(_orders)) {
      await removeOrder(order.id);
    }
  }

  // البحث في الطلبات
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.coffeeName.toLowerCase().contains(lowercaseQuery) ||
          order.id.toLowerCase().contains(lowercaseQuery) ||
          order.status.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // الحصول على إحصائيات الطلبات
  Map<String, int> get orderStatistics {
    final stats = <String, int>{
      'total': _orders.length,
      'processing': getOrdersByStatus('processing').length,
      'delivered': getOrdersByStatus('delivered').length,
      'cancelled': getOrdersByStatus('cancelled').length,
    };
    return stats;
  }

  // تحديث الطلب بعد التوصيل
  void markOrderAsDelivered(String orderId) {
    updateOrderStatus(orderId, 'Delivered');
  }

  // إلغاء الطلب
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, 'Cancelled');
  }

  // إعادة الطلب
  void reorder(String orderId) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coffeeName: order.coffeeName,
      coffeeImage: order.coffeeImage,
      price: order.price,
      quantity: order.quantity,
      size: order.size,
      isDairyFree: order.isDairyFree,
      orderDate: DateTime.now(),
      status: 'Pending',
    );
    addOrder(newOrder);
  }

  // الحصول على الطلبات لهذا الشهر
  List<Order> get ordersThisMonth {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    return _orders
        .where((order) => order.orderDate.isAfter(firstDayOfMonth))
        .toList();
  }

  // الحصول على الطلبات الشائعة
  Map<String, int> get popularOrders {
    final coffeeCount = <String, int>{};

    for (final order in _orders) {
      coffeeCount[order.coffeeName] =
          (coffeeCount[order.coffeeName] ?? 0) + order.quantity;
    }

    return coffeeCount;
  }

  // مسح الطلبات الملغية
  Future<void> clearCancelledOrders() async {
    final cancelledOrders = _orders.where((order) => order.status.toLowerCase() == 'cancelled').toList();
    for (var order in cancelledOrders) {
      await removeOrder(order.id);
    }
  }

  Future<bool> addCoffee(Coffee newCoffee) async {
    try {
      final addedCoffee = await _coffeeService.addCoffee(newCoffee);
      if (addedCoffee == null) {
        _error = 'Failed to add coffee';
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
