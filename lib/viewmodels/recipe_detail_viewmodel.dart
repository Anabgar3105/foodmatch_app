import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/local/app_database.dart';
import '../models/recipe.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  RecipeDetailViewModel({
    RecipeRepository? repository,
    AppDatabase? database,
  }) : _repository =
           repository ?? RecipeRepository(ApiClient(), localDb: database);

  bool _isLoading = false;
  String? _errorMessage;
  RecipeDetailDto? _recipe;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecipeDetailDto? get recipe => _recipe;

  Future<void> fetchRecipeDetail(int recipeId) async {
    _isLoading = true;
    _errorMessage = null;
    _recipe = null;
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

  Future<bool> updateRecipe({
    required int recipeId,
    required String title,
    required int preparationTime,
    required String category,
    required String? localImagePath,
    required String? existingImageUrl,
    required List<Map<String, String>> ingredients,
    required List<String> steps,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? finalImageUrl = existingImageUrl;

      // Si hay una nueva imagen, subirla
      if (localImagePath != null) {
        finalImageUrl = await _repository.uploadRecipeImage(localImagePath);
      }

      final updatedRecipe = RecipeCreateDto(
        title: title,
        preparationTime: preparationTime,
        category: category,
        image: finalImageUrl ?? '',
        ingredients: ingredients,
        elaborationSteps: steps.map((s) => {'instruction': s}).toList(),
      );

      _recipe = await _repository.updateRecipe(recipeId, updatedRecipe);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateRecipeFromEdit(RecipeDetailDto updatedRecipe) {
    _recipe = updatedRecipe;
    notifyListeners();
  }
}
