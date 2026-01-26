import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coffee_model.dart';

class ApiService {
  // استخدام API مجاني للقهوة https://fakestoreapi.com/products
  static const String _coffeeApiUrl = 'https://api.sampleapis.com/coffee/hot';

  Future<List<Coffee>> getCoffees() async {
    try {
      final response = await http.get(
        Uri.parse(_coffeeApiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return _getDefaultCoffees();
        }

        return data.map((json) {
          return Coffee(
            id: json['id']?.toString() ??
                '${DateTime.now().millisecondsSinceEpoch}',
            name: json['title'] ?? json['name'] ?? 'Coffee',
            description: json['description'] ?? 'Delicious coffee drink',
            price: (json['price'] as num?)?.toDouble() ?? 3.99,
            imageUrl: json['image'] ??
                'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
            rating: 4.5,
            reviewCount: 100,
            category: 'All Coffee',
          );
        }).toList();
      } else {
        return _getDefaultCoffees();
      }
    } catch (e) {
      print('Error fetching coffees: $e');
      return _getDefaultCoffees();
    }
  }

  List<Coffee> _getDefaultCoffees() {
    return [
      Coffee(
        id: '1',
        name: 'Caffe Mocha',
        description:
            'A delightful blend of espresso, chocolate, and steamed milk',
        price: 4.53,
        imageUrl:
            'https://images.unsplash.com/photo-1568649929103-28ffbefaca1e?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        rating: 4.8,
        reviewCount: 2500,
        category: 'All Coffee',
      ),
      Coffee(
        id: '2',
        name: 'Flat White',
        description: 'Smooth espresso with velvety microfoam',
        price: 3.53,
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        rating: 4.5,
        reviewCount: 1800,
        category: 'All Coffee',
      ),
      Coffee(
        id: '3',
        name: 'Espresso',
        description:
            'Strong black coffee made by forcing steam through ground coffee beans',
        price: 2.50,
        imageUrl:
            'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        rating: 4.7,
        reviewCount: 3200,
        category: 'All Coffee',
      ),
      Coffee(
        id: '4',
        name: 'Cappuccino',
        description: 'Espresso with steamed milk foam',
        price: 3.75,
        imageUrl:
            'https://images.unsplash.com/photo-1572442388796-11668a67e53d?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80',
        rating: 4.6,
        reviewCount: 2100,
        category: 'All Coffee',
      ),
    ];
  }
}
