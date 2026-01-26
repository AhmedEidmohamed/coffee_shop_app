import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isArabic = false;

  Locale get locale => _locale;
  bool get isArabic => _isArabic;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _isArabic = languageCode == 'ar';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    _isArabic = languageCode == 'ar';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    
    if (_isArabic) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    
    notifyListeners();
  }
}