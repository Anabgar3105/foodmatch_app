/// ViewModel for managing application theme.
///
/// Handles theme selection and persistence.
/// Supports light, dark, and system themes.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for managing application theme.
class ThemeViewModel extends ChangeNotifier {
  /// Current theme mode
  late ThemeMode _themeMode;

  /// Creates a [ThemeViewModel] instance with initial theme mode.
  ///
  /// Parameters:
  ///   - [initialMode]: The initial theme mode to use
  ThemeViewModel(ThemeMode initialMode) {
    _themeMode = initialMode;
  }

  /// Current application theme mode
  ThemeMode get themeMode => _themeMode;

  /// Toggles between light and dark theme.
  ///
  /// Saves preference to SharedPreferences for persistence.
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
