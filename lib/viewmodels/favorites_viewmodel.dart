import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/favorite_repository.dart';
import '../data/api_client.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoriteRepository _repository;

  FavoritesViewModel({FavoriteRepository? repository}) 
      : _repository = repository ?? FavoriteRepository(ApiClient());

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
}