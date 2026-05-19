import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeViewModel(ThemeMode initialMode) {
    _themeMode = initialMode;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await prefs.setString('theme_preference', 'light'); 
    } else {
      _themeMode = ThemeMode.dark;
      await prefs.setString('theme_preference', 'dark');  
    }
    
    notifyListeners(); 
  }
}