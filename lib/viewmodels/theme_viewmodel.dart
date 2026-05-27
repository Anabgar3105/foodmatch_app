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

  /// Generates storage key for theme preference (user-specific if logged in)
  /// Retrieves username dynamically from SharedPreferences
  Future<String> _getThemeKey() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('auth_username');

    if (username != null && username.isNotEmpty) {
      return 'theme_preference_$username';
    }
    return 'theme_preference';
  }

  /// Toggles between light and dark theme.
  ///
  /// Saves preference to SharedPreferences for persistence.
  /// Uses user-specific key if username is available.
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeKey = await _getThemeKey();

    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await prefs.setString(themeKey, 'light');
    } else {
      _themeMode = ThemeMode.dark;
      await prefs.setString(themeKey, 'dark');
    }

    notifyListeners();
  }

  /// Reloads the theme preference for the currently logged-in user.
  /// Call this method after a user logs in to switch to their saved theme.
  Future<void> reloadUserTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeKey = await _getThemeKey();
    final savedTheme = prefs.getString(themeKey);

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Resets theme to default (system)
  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
