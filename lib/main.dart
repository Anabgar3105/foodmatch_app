/// Main entry point for the FoodMatch application.
///
/// This file initializes the application with:
/// - Token validation and automatic logout on expiration
/// - Theme preference persistence
/// - Provider setup for state management
/// - Navigation configuration
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/add_recipe_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/profile_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_detail_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/signup_viewmodel.dart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';

/// Global navigator key for accessing navigation context from anywhere in the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Checks if a JWT token has expired.
///
/// Decodes the JWT payload and compares the `exp` claim with the current time.
/// Returns `true` if the token is expired or invalid.
///
/// Parameters:
///   - [token]: The JWT token string to validate
///
/// Returns: `true` if token is expired or invalid, `false` if valid
bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);

    if (payloadMap is! Map<String, dynamic>) return true;

    final exp = payloadMap['exp'];
    if (exp == null) return true;

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  } catch (e) {
    // Si ocurre cualquier error al decodificar el token, hacemos un segundo intento
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalized);
      final resp = utf8.decode(decodedBytes);
      final payloadMap = json.decode(resp);

      if (payloadMap is! Map<String, dynamic>) return true;

      final exp = payloadMap['exp'];
      if (exp == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }
}

/// Initializes and runs the FoodMatch application.
///
/// Performs the following initialization tasks:
/// 1. Validates stored authentication token
/// 2. Loads saved theme preference
/// 3. Sets initial route (login or main)
/// 4. Configures all ViewModels via Provider
///
/// If token is expired, clears preferences and redirects to login.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  final String? username = prefs.getString('auth_username');

  String initialRoute = AppRoutes.login;

  if (token != null && token.isNotEmpty) {
    if (!isTokenExpired(token)) {
      initialRoute = AppRoutes.main;
    } else {
      await prefs.clear();
    }
  }

  // Load user-specific theme preference if logged in, otherwise use general preference
  final String themeKey = (username != null && username.isNotEmpty)
      ? 'theme_preference_$username'
      : 'theme_preference';
  final String? savedTheme = prefs.getString(themeKey);
  
  ThemeMode initialThemeMode;

  if (savedTheme == 'dark') {
    initialThemeMode = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    initialThemeMode = ThemeMode.light;
  } else {
    initialThemeMode = ThemeMode.system;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(initialThemeMode),
        ),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeDetailViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => AddRecipeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: FoodMatchApp(initialRoute: initialRoute),
    ),
  );
}

class FoodMatchApp extends StatelessWidget {
  final String initialRoute;

  const FoodMatchApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'FoodMatch',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
