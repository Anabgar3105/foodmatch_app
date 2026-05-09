import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/main_layout.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main'; // Layout principal con tabs

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      main: (context) => const MainLayout(),
    };
  }
}