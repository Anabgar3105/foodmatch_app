/// Central configuration for all application routes.
///
/// Defines route names as constants and provides a static getter
/// for a map of routes to screen builders.
///
/// Usage:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.main);
/// ```
library;
import 'package:flutter/material.dart';
import 'package:foodmatch_app/views/recipe_swipe_view.dart';
import 'package:foodmatch_app/views/signup_view.dart';
import 'package:foodmatch_app/views/add_recipe_view.dart';
import '../views/login_view.dart';
import '../views/main_layout.dart';

/// Route configuration class containing all application routes.
class AppRoutes {
  /// Route name for login screen
  static const String login = '/login';

  /// Route name for signup screen
  static const String signup = '/signup';

  /// Route name for main app layout (authenticated users)
  static const String main = '/main';

  /// Route name for recipe swipe screen
  static const String swipe = '/recipes';

  /// Route name for add/edit recipe screen
  static const String addRecipe = '/add-recipe';

  /// Returns a map of route names to corresponding screen builders.
  /// Used by MaterialApp for named route navigation.
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      main: (context) => const MainLayout(),
      swipe: (context) => const RecipeSwipeScreen(),
      addRecipe: (context) => const AddRecipeScreen(),
    };
  }
}
