import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/local/app_database.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;
  final RecipeRepository _recipeRepository;

  FavoritesViewModel({
    FavoriteRepository? repository,
    RecipeRepository? recipeRepository,
    AppDatabase? database,
  }) : _repository =
           repository ??
           FavoriteRepository(
             ApiClient(),
             recipeRepository ??
                 RecipeRepository(ApiClient(), localDb: database),
             localDb: database,
           ),
       _recipeRepository =
           recipeRepository ?? RecipeRepository(ApiClient(), localDb: database);

  bool _isLoading = false;
  String? _errorMessage;
  List<RecipeCardDto> _favorites = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RecipeCardDto> get favorites => _favorites;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      _favorites = await _repository.getFavorites();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
