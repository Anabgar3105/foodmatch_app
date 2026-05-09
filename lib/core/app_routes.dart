import 'package:flutter/material.dart';
import 'package:foodmatch_app/views/recipe_swipe_view.dart';
import '../views/login_view.dart';
import '../views/main_layout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';
  static const String swipe = '/recipes'; 

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      main: (context) => const MainLayout(),
      swipe: (context) => const RecipeSwipeScreen(),
    };
  }
}