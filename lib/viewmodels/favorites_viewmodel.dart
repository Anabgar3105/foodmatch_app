/// ViewModel for managing user's favorite recipes.
///
/// Handles fetching, removing, and updating favorites.
/// Manages loading state and errors during favorite operations.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for managing favorite recipes.
class FavoritesViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;
  final RecipeRepository _recipeRepository;

  /// Creates a [FavoritesViewModel] instance.
  ///
  /// Optionally accepts custom repository instances for testing.
  FavoritesViewModel({
    FavoriteRepository? repository,
    RecipeRepository? recipeRepository,
  }) : _repository = repository ?? FavoriteRepository(ApiClient()),
       _recipeRepository = recipeRepository ?? RecipeRepository(ApiClient());

  /// Whether favorites are currently being loaded
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// List of user's favorite recipes
  List<RecipeCardDto> _favorites = [];

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// List of favorite recipes
  List<RecipeCardDto> get favorites => _favorites;

  /// Fetches the user's favorite recipes.
  ///
  /// Sets loading state and handles errors automatically.
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _favorites = await _repository.getFavorites();
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes a recipe from favorites.
  ///
  /// Removes from local state immediately and notifies listeners.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID to remove from favorites
  Future<void> removeFavorite(int recipeId) async {
    try {
      await _repository.removeFavorite(recipeId);
      _favorites.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al borrar favorito: $e');
    }
  }

  /// Updates a favorite recipe with fresh data from the server.
  ///
  /// Reloads recipe details and updates the favorites list.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID to update
  Future<void> updateFavoriteRecipe(int recipeId) async {
    try {
      final index = _favorites.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        // Recargar la receta actualizada desde el servidor
        final updatedRecipe = await _recipeRepository.getRecipeDetail(recipeId);
        _favorites[index] = RecipeCardDto(
          id: updatedRecipe.id,
          title: updatedRecipe.title,
          preparationTime: updatedRecipe.preparationTime,
          category: updatedRecipe.category,
          image: updatedRecipe.image,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar favorito: $e');
    }
  }
}
