import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  // Por defecto respetar la configuración del móvil del usuario
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}