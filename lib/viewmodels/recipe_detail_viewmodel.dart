import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  RecipeDetailViewModel({RecipeRepository? repository}) 
      : _repository = repository ?? RecipeRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;
  RecipeDetailDto? _recipe;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecipeDetailDto? get recipe => _recipe;

  Future<void> fetchRecipeDetail(int recipeId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners()); 

    try {
      _recipe = await _repository.getRecipeDetail(recipeId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _recipe = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}