import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';
import 'viewmodels/theme_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ],
      child: const FoodMatchApp(),
    ),
  );
}

class FoodMatchApp extends StatelessWidget {
  const FoodMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del tema
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'FoodMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
