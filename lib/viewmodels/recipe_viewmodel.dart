import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/recipe_repository.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;
  final FavoriteRepository _favoriteRepository;

  RecipeViewModel({
    RecipeRepository? repository,
    FavoriteRepository? favoriteRepository,
  }) : _repository = repository ?? RecipeRepository(ApiClient()),
       _favoriteRepository =
           favoriteRepository ?? FavoriteRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;
  List<RecipeCardDto> _recipes = [];
  final Set<int> _favoritedIds = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RecipeCardDto> get recipes => _recipes;
  bool isFavorite(int id) => _favoritedIds.contains(id);

  Future<void> fetchRecipes({String? category, int? maxTime}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _repository.searchRecipes(
        category: category,
        maxTime: maxTime,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveFavorite(int recipeId) async {
    try {
      await _favoriteRepository.addFavorite(recipeId);
      debugPrint('Receta $recipeId guardada en favoritos correctamente');
    } catch (e) {
      _errorMessage =
          'Error al guardar la receta en favoritos: ${e.toString().replaceAll('Exception: ', '')}';
      debugPrint('Error al guardar favorito: $e');
    }
  }

  // Cambiamos a Future<bool> para avisar a la vista del resultado
  Future<bool> toggleFavorite(int recipeId) async {
    final wasFavorite = _favoritedIds.contains(recipeId);

    // 1. ACTUALIZACIÓN OPTIMISTA
    if (wasFavorite) {
      _favoritedIds.remove(recipeId);
    } else {
      _favoritedIds.add(recipeId);
    }
    notifyListeners(); 

    // 2. Llamada al backend
    try {
      if (!wasFavorite) {
        await _favoriteRepository.addFavorite(recipeId);
      } else {
        await _favoriteRepository.removeFavorite(recipeId);
      }
      return true;
      
    } catch (e) {
      debugPrint('Error del backend: $e');
      
      // 3. REVERTIMOS SI FALLA
      if (wasFavorite) {
        _favoritedIds.add(recipeId);
      } else {
        _favoritedIds.remove(recipeId);
      }
      notifyListeners(); 
      
      return false; 
    }
  }
}
