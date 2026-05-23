import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/add_recipe_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/profile_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_detail_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/signup_viewmodel.dart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/local/app_database.dart';
import 'data/api_client.dart';
import 'data/services/sync_service.dart';
import 'data/services/connectivity_service.dart';
import 'widgets/app_initializer.dart';
import 'core/theme.dart';
import 'core/app_routes.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    return true; 
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar BD local (v4 - tablas con nombres correctos)
  final database = await $FloorAppDatabase
      .databaseBuilder('foodmatch_app.db')
      .build();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  String initialRoute = AppRoutes.login;
  
  if (token != null && token.isNotEmpty) {
    if (!isTokenExpired(token)) {
      initialRoute = AppRoutes.main; 
    } else {
      await prefs.clear(); 
    }
  }

  final String? savedTheme = prefs.getString('theme_preference');
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
        // Base de datos
        Provider<AppDatabase>(create: (_) => database),
        
        // API Client
        Provider<ApiClient>(create: (_) => ApiClient()),
        
        // Sync Service
        ProxyProvider<ApiClient, SyncService>(
          create: (context) => SyncService(
            context.read<ApiClient>(),
            localDb: database,
          ),
          update: (context, apiClient, previous) => SyncService(
            apiClient,
            localDb: database,
          ),
        ),
        
        // Connectivity Service con auto-sync
        ProxyProvider<SyncService, ConnectivityService>(
          create: (context) {
            final service = ConnectivityService(
              syncService: context.read<SyncService>(),
            );
            service.init();
            return service;
          },
          update: (context, syncService, previous) {
            return previous ?? ConnectivityService(
              syncService: syncService,
            );
          },
        ),
        
        // Theme
        ChangeNotifierProvider(create: (_) => ThemeViewModel(initialThemeMode)),
        
        // ViewModels
        ChangeNotifierProvider(
          create: (context) => RecipeViewModel(database: context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesViewModel(database: context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(
          create: (context) => RecipeDetailViewModel(database: context.read<AppDatabase>()),
        ),
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

    return AppInitializer(
      child: MaterialApp(
        title: 'FoodMatch',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, 
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeViewModel.themeMode,
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}