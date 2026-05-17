import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';

class AddRecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  AddRecipeViewModel({RecipeRepository? repository})
    : _repository = repository ?? RecipeRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> saveRecipe({
    required String title,
    required int time,
    required String category,
    required String imagePath,
    required List<Map<String, String>> ingredients,
    required List<String> steps,
  }) async {
    _isLoading = true;
    _errorMessage = null;
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
