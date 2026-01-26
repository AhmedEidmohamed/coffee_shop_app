import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  String _name = 'Ahmed Mohamed';
  String _email = 'ahmed@example.com';
  String _phone = '+201234567890';
  String _address = 'Cairo, Egypt';
  String? _profileImage;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String? get profileImage => _profileImage;

  ProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    _name = prefs.getString('profile_name') ?? 'Ahmed Mohamed';
    _email = prefs.getString('profile_email') ?? 'ahmed@example.com';
    _phone = prefs.getString('profile_phone') ?? '+201234567890';
    _address = prefs.getString('profile_address') ?? 'Cairo, Egypt';
    _profileImage = prefs.getString('profile_image');
    
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? profileImage,
  }) async {
    _name = name;
    _email = email;
    _phone = phone;
    _address = address;
    
    if (profileImage != null) {
      _profileImage = profileImage;
    }

    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_email', email);
    await prefs.setString('profile_phone', phone);
    await prefs.setString('profile_address', address);
    
    if (profileImage != null) {
      await prefs.setString('profile_image', profileImage);
    }
    
    notifyListeners();
  }

  void clearProfile() {
    _name = 'Ahmed Mohamed';
    _email = 'ahmed@example.com';
    _phone = '+201234567890';
    _address = 'Cairo, Egypt';
    _profileImage = null;
    
    notifyListeners();
  }
}