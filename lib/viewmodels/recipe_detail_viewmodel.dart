/// ViewModel for displaying and managing recipe details.
///
/// Handles fetching detailed recipe information including ingredients
/// and preparation steps. Supports recipe updates with image upload.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_repository.dart';
import '../data/api_client.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for recipe detail view.
class RecipeDetailViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  /// Creates a [RecipeDetailViewModel] instance.
  ///
  /// Optionally accepts custom repository instance for testing.
  RecipeDetailViewModel({RecipeRepository? repository})
    : _repository = repository ?? RecipeRepository(ApiClient());

  /// Whether recipe is currently being loaded
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// The detailed recipe information
  RecipeDetailDto? _recipe;

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// The detailed recipe data
  RecipeDetailDto? get recipe => _recipe;

  /// Fetches detailed recipe information.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID to fetch
  Future<void> fetchRecipeDetail(int recipeId) async {
    _isLoading = true;
    _error = null;
    _recipe = null;
    Future.microtask(() => notifyListeners());

    try {
      _recipe = await _repository.getRecipeDetail(recipeId);
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _recipe = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates a recipe with new information.
  ///
  /// Handles image upload if a new image is provided,
  /// then sends the update to the backend.
  ///
  /// Parameters:
  ///   - [recipeId]: The recipe ID to update
  ///   - [title]: Updated recipe title
  ///   - [preparationTime]: Updated preparation time in minutes
  ///   - [category]: Updated recipe category
  ///   - [localImagePath]: New image file path (optional)
  ///   - [existingImageUrl]: Current image URL (used if no new image)
  ///   - [ingredients]: Updated list of ingredients
  ///   - [steps]: Updated list of preparation steps
  ///
  /// Returns: true if update succeeded, false otherwise
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
    _error = null;
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
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates local recipe state after edit.
  ///
  /// Used to reflect changes made to the recipe.
  ///
  /// Parameters:
  ///   - [updatedRecipe]: The updated recipe details
  void updateRecipeFromEdit(RecipeDetailDto updatedRecipe) {
    _recipe = updatedRecipe;
    notifyListeners();
  }
}
