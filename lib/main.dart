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

Future<void> main() async {
  // Asegurar la comunicación nativa antes de inicializar SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  //Comprobamos si existe un token guardado en el almacenamiento local
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  // Configuramos pantalla inicial según la existencia del token
  final String initialRoute = (token != null && token.isNotEmpty)
      ? AppRoutes.main
      : AppRoutes.login;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
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
    // Escuchamos los cambios del tema
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'FoodMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
