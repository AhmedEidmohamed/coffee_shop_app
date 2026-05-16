import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/coffee_model.dart';

class FirestoreOrderService {
  FirebaseFirestore? _firestoreInstance;

  FirebaseFirestore? get _firestore {
    try {
      _firestoreInstance ??= FirebaseFirestore.instance;
      return _firestoreInstance;
    } catch (e) {
      print('Firebase not initialized: $e');
      return null;
    }
  }

  Future<List<Order>> getOrders() async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore!.collection('orders').orderBy('orderDate', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; // overwrite id with document id
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching orders from Firestore: $e');
      return [];
    }
  }

  Future<Order?> addOrder(Order order) async {
    if (_firestore == null) return null;
    try {
      final docRef = await _firestore!.collection('orders').add(order.toJson());
      // Return order with real Firestore ID
      return Order(
        id: docRef.id,
        coffeeName: order.coffeeName,
        coffeeImage: order.coffeeImage,
        price: order.price,
        quantity: order.quantity,
        size: order.size,
        isDairyFree: order.isDairyFree,
        orderDate: order.orderDate,
        status: order.status,
      );
    } catch (e) {
      print('Error adding order to Firestore: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    if (_firestore == null) return false;
    try {
      await _firestore!.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      return true;
    } catch (e) {
      print('Error updating order status in Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    if (_firestore == null) return false;
    try {
      await _firestore!.collection('orders').doc(orderId).delete();
      return true;
    } catch (e) {
      print('Error deleting order in Firestore: $e');
      return false;
    }
  }
}
