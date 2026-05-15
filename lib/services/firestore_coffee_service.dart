import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coffee_model.dart';

class FirestoreCoffeeService {
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

  Future<List<Coffee>> getCoffees() async {
    if (_firestore == null) return [];
    try {
      final snapshot = await _firestore!.collection('coffees').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Coffee(
          id: doc.id,
          name: data['name'] ?? 'Coffee',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
          reviewCount: data['reviewCount'] ?? 0,
          category: data['category'] ?? 'All Coffee',
        );
      }).toList();
    } catch (e) {
      print('Error fetching coffees from Firestore: $e');
      return [];
    }
  }

  Future<Coffee?> addCoffee(Coffee newCoffee) async {
    if (_firestore == null) return null;
    try {
      final docRef = await _firestore!.collection('coffees').add({
        'name': newCoffee.name,
        'description': newCoffee.description,
        'price': newCoffee.price,
        'imageUrl': newCoffee.imageUrl,
        'rating': newCoffee.rating,
        'reviewCount': newCoffee.reviewCount,
        'category': newCoffee.category,
      });

      return newCoffee.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding coffee to Firestore: $e');
      return null;
    }
  }

  Future<bool> updateCoffee(String id, Coffee updatedCoffee) async {
    if (_firestore == null) return false;
    try {
      await _firestore!.collection('coffees').doc(id).update({
        'name': updatedCoffee.name,
        'description': updatedCoffee.description,
        'price': updatedCoffee.price,
        'imageUrl': updatedCoffee.imageUrl,
        'category': updatedCoffee.category,
      });
      return true;
    } catch (e) {
      print('Error updating coffee in Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteCoffee(String id) async {
    if (_firestore == null) return false;
    try {
      await _firestore!.collection('coffees').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting coffee in Firestore: $e');
      return false;
    }
  }
}
