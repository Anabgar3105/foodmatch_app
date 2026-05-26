import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;
  final RecipeRepository _recipeRepository;

  FavoritesViewModel({
    FavoriteRepository? repository,
    RecipeRepository? recipeRepository,
  }) : _repository = repository ?? FavoriteRepository(ApiClient()),
       _recipeRepository = recipeRepository ?? RecipeRepository(ApiClient());

  bool _isLoading = false;
  AppError? _error;
  List<RecipeCardDto> _favorites = [];

  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.userMessage;
  List<RecipeCardDto> get favorites => _favorites;

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

  Future<void> removeFavorite(int recipeId) async {
    try {
      await _repository.removeFavorite(recipeId);
      _favorites.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al borrar favorito: $e');
    }
  }

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
