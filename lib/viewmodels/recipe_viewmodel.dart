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

      final userFavorites = await _favoriteRepository.getFavorites();
      
      _favoritedIds.clear();
      _favoritedIds.addAll(userFavorites.map((recipe) => recipe.id));

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void updateFavoriteLocal(int recipeId, bool isFavorite) {
    if (isFavorite) {
      _favoritedIds.add(recipeId);
    } else {
      _favoritedIds.remove(recipeId);
    }
    notifyListeners();
  }
}
