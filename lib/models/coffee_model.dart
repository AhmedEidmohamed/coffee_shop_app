class Coffee {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  
  // أضف هذه الحقول
  bool isFavorite;
  final bool isHot;
  final bool hasMilk;
  final bool isDairyFree; // بدلاً من var
  final List<String> ingredients;
  final List<String> sizes;
  final List<String> addons;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    // قيم افتراضية للحقول الجديدة
    this.isFavorite = false,
    this.isHot = true,
    this.hasMilk = false,
    this.isDairyFree = false,
    this.ingredients = const [],
    this.sizes = const ['Small', 'Medium', 'Large'],
    this.addons = const [],
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? 'Coffee',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 
              (json['rating']?['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 
                   (json['rating']?['count'] as num?)?.toInt() ?? 0,
      category: json['category'] ?? 'All Coffee',
      // أضف القيم الجديدة من JSON أو استخدم قيم افتراضية
      isFavorite: json['isFavorite'] ?? false,
      isHot: json['isHot'] ?? true,
      hasMilk: json['hasMilk'] ?? false,
      isDairyFree: json['isDairyFree'] ?? false,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? ['Small', 'Medium', 'Large']),
      addons: List<String>.from(json['addons'] ?? []),
    );
  }

  // دالة copyWith لتحديث القيم
  Coffee copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? category,
    bool? isFavorite,
    bool? isHot,
    bool? hasMilk,
    bool? isDairyFree,
    List<String>? ingredients,
    List<String>? sizes,
    List<String>? addons,
  }) {
    return Coffee(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isHot: isHot ?? this.isHot,
      hasMilk: hasMilk ?? this.hasMilk,
      isDairyFree: isDairyFree ?? this.isDairyFree,
      ingredients: ingredients ?? this.ingredients,
      sizes: sizes ?? this.sizes,
      addons: addons ?? this.addons,
    );
  }

  // دالة toJson لحفظ البيانات
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'isFavorite': isFavorite,
      'isHot': isHot,
      'hasMilk': hasMilk,
      'isDairyFree': isDairyFree,
      'ingredients': ingredients,
      'sizes': sizes,
      'addons': addons,
    };
  }
}

class Order {
  final String id;
  final String coffeeName;
  final String coffeeImage;
  final double price;
  final int quantity;
  final String size;
  final bool isDairyFree;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.coffeeName,
    required this.coffeeImage,
    required this.price,
    required this.quantity,
    required this.size,
    required this.isDairyFree,
    required this.orderDate,
    required this.status,
  });

  double get totalPrice => price * quantity;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(orderDate);
    
    if (difference.inDays > 7) {
      return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coffeeName': coffeeName,
      'coffeeImage': coffeeImage,
      'price': price,
      'quantity': quantity,
      'size': size,
      'isDairyFree': isDairyFree,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      coffeeName: json['coffeeName'] ?? '',
      coffeeImage: json['coffeeImage'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? 'Medium',
      isDairyFree: json['isDairyFree'] ?? false,
      orderDate: json['orderDate'] != null 
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
      status: json['status'] ?? 'Processing',
    );
  }
}