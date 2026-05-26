/// ViewModel for managing recipe search and display.
///
/// Handles fetching recipes, tracking favorites, and toggling favorite status.
/// Manages loading state and errors during recipe operations.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/recipe_repository.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for recipe search and management.
class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;
  final FavoriteRepository _favoriteRepository;

  /// Creates a [RecipeViewModel] instance.
  ///
  /// Optionally accepts custom repository instances for testing.
  RecipeViewModel({
    RecipeRepository? repository,
    FavoriteRepository? favoriteRepository,
  }) : _repository = repository ?? RecipeRepository(ApiClient()),
       _favoriteRepository =
           favoriteRepository ?? FavoriteRepository(ApiClient());

  /// Whether recipes are currently being loaded
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// List of fetched recipes
  List<RecipeCardDto> _recipes = [];

  /// Set of IDs for recipes marked as favorite
  final Set<int> _favoritedIds = {};

  /// List of recipes created by current user
  List<RecipeCardDto> _myRecipes = [];

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// List of available recipes
  List<RecipeCardDto> get recipes => _recipes;

  /// List of user's recipes
  List<RecipeCardDto> get myRecipes => _myRecipes;

  /// Checks if a recipe is marked as favorite.
  ///
  /// Parameters:
  ///   - [id]: The recipe ID to check
  ///
  /// Returns: true if recipe is favorited
  bool isFavorite(int id) => _favoritedIds.contains(id);

  /// Fetches recipes with optional filters.
  ///
  /// Sets loading state and handles errors automatically.
  /// Fetches user's favorite list and updates internal state.
  ///
  /// Parameters:
  ///   - [category]: Optional category filter
  ///   - [maxTime]: Optional maximum preparation time filter
  Future<void> fetchRecipes({String? category, int? maxTime}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _repository.searchRecipes(
        category: category,
        maxTime: maxTime,
      );

      final userFavorites = await _favoriteRepository.getFavorites();

      _favoritedIds.clear();
      _favoritedIds.addAll(userFavorites.map((recipe) => recipe.id));
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles favorite status for a recipe.
  ///
  /// Immediately updates UI, then syncs with backend.
  /// Reverts if backend request fails.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID to toggle
  ///
  /// Returns: true if operation succeeded, false if failed
  Future<bool> toggleFavorite(int recipeId) async {
    final wasFavorite = _favoritedIds.contains(recipeId);

    if (wasFavorite) {
      _favoritedIds.remove(recipeId);
    } else {
      _favoritedIds.add(recipeId);
    }
    notifyListeners();

    try {
      if (!wasFavorite) {
        await _favoriteRepository.addFavorite(recipeId);
      } else {
        await _favoriteRepository.removeFavorite(recipeId);
      }
      return true;
    } catch (e) {
      debugPrint('Error del backend: $e');

      if (wasFavorite) {
        _favoritedIds.add(recipeId);
      } else {
        _favoritedIds.remove(recipeId);
      }
      notifyListeners();

      return false;
    }
  }

  /// Updates favorite status locally without API call.
  ///
  /// Used for local state synchronization.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID
  ///   - [isFavorite]: Whether the recipe is favorite
  void updateFavoriteLocal(int recipeId, bool isFavorite) {
    if (isFavorite) {
      _favoritedIds.add(recipeId);
    } else {
      _favoritedIds.remove(recipeId);
    }
    notifyListeners();
  }

  // 1. Obtener mis recetas personales
  Future<void> fetchMyRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myRecipes = await _repository.getMyRecipes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Borrar receta
  Future<bool> deleteRecipe(int recipeId) async {
    try {
      await _repository.deleteRecipe(recipeId);

      _myRecipes.removeWhere((recipe) => recipe.id == recipeId);

      _recipes.removeWhere((recipe) => recipe.id == recipeId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      notifyListeners();
      return false;
    }
  }
}
