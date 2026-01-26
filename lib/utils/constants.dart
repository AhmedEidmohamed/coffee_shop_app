import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6F4E37);
  static const Color secondaryColor = Color(0xFF8B7355);
  static const Color backgroundColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  // API
  static const String coffeeApiUrl = 'https://api.sampleapis.com/coffee/hot';
  
  // Local Storage Keys
  static const String themeKey = 'isDarkMode';
  static const String languageKey = 'language';
  static const String userKey = 'user';
  
  // Fonts
  static const String arabicFont = 'Cairo';
  static const String englishFont = 'Inter';
  
  // Images
  static const String defaultCoffeeImage = 
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400';
}

class AppRoutes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String delivery = '/delivery';
  static const String confirmation = '/confirmation';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
}