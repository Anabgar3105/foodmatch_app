import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/recipe_repository.dart';
import '../models/recipe.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  RecipeViewModel({RecipeRepository? repository}) 
      : _repository = repository ?? RecipeRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;
  List<RecipeCardDto> _recipes = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RecipeCardDto> get recipes => _recipes;

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
}