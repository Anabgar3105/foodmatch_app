/// ViewModel for creating and managing recipe creation/editing.
///
/// Handles recipe creation with image upload and recipe updates.
/// Manages loading state and errors during recipe operations.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for recipe creation and editing.
class AddRecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  /// Creates an [AddRecipeViewModel] instance.
  ///
  /// Optionally accepts custom repository instance for testing.
  AddRecipeViewModel({RecipeRepository? repository})
    : _repository = repository ?? RecipeRepository(ApiClient());

  /// Whether recipe is currently being saved
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// The recipe being edited (if applicable)
  RecipeDetailDto? _recipe;

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// Recipe being edited
  RecipeDetailDto? get recipe => _recipe;

  /// Saves a new recipe to the backend.
  ///
  /// Uploads the image first, then creates the recipe in the database.
  ///
  /// Parameters:
  ///   - [title]: Recipe title
  ///   - [time]: Preparation time in minutes
  ///   - [category]: Recipe category
  ///   - [imagePath]: Local file path to the recipe image
  ///   - [ingredients]: List of ingredients with names and quantities
  ///   - [steps]: List of preparation step instructions
  ///
  /// Returns: true if save succeeded, false otherwise
  Future<bool> saveRecipe({
    required String title,
    required int time,
    required String category,
    required String imagePath,
    required List<Map<String, String>> ingredients,
    required List<String> steps,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Subir la foto a Cloudinary
      final imageUrl = await _repository.uploadRecipeImage(imagePath);

      // Construir el DTO
      final newRecipe = RecipeCreateDto(
        title: title,
        preparationTime: time,
        category: category,
        image: imageUrl,
        ingredients: ingredients,
        elaborationSteps: steps.map((s) => {'description': s}).toList(),
      );

      // Guardar en la base de datos
      await _repository.createRecipe(newRecipe);

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

  /// Updates an existing recipe.
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

      // Actualizar receta en el backend
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
}
