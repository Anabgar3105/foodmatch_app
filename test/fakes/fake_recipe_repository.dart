import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/recipe_repository.dart';
import 'package:foodmatch_app/models/recipe.dart';

/// Fake Repository para testing con datos simulados
/// Simula las respuestas sin hacer llamadas reales a la API
class FakeRecipeRepository extends RecipeRepository {
  FakeRecipeRepository() : super(FakeApiClient());

  bool shouldFail = false;
  String? errorMsg;

  // Datos simulados
  static final List<RecipeCardDto> _mockRecipes = [
    RecipeCardDto(
      id: 1,
      title: 'Pasta Carbonara',
      preparationTime: 20,
      category: 'PLATOS_COMPLETOS',
      image: 'https://example.com/carbonara.jpg',
    ),
    RecipeCardDto(
      id: 2,
      title: 'Ensalada César',
      preparationTime: 10,
      category: 'ENTRANTES',
      image: 'https://example.com/caesar.jpg',
    ),
    RecipeCardDto(
      id: 3,
      title: 'Brownie de Chocolate',
      preparationTime: 30,
      category: 'POSTRES',
      image: 'https://example.com/brownie.jpg',
    ),
    RecipeCardDto(
      id: 4,
      title: 'Chips Caseros',
      preparationTime: 15,
      category: 'SNACKS',
      image: 'https://example.com/chips.jpg',
    ),
  ];

  static final Map<int, RecipeDetailDto> _mockDetails = {
    1: RecipeDetailDto(
      id: 1,
      title: 'Pasta Carbonara',
      image: 'https://example.com/carbonara.jpg',
      category: 'PLATOS_COMPLETOS',
      preparationTime: 20,
      ingredients: [
        IngredientDto(name: 'Pasta', quantity: '400g'),
        IngredientDto(name: 'Huevo', quantity: '4 unidades'),
        IngredientDto(name: 'Panceta', quantity: '200g'),
        IngredientDto(name: 'Queso Pecorino', quantity: '100g'),
      ],
      elaborationSteps: [
        ElaborationStepDto(
          stepNumber: 1,
          description: 'Cocinar la pasta en agua salada',
        ),
        ElaborationStepDto(
          stepNumber: 2,
          description: 'Mezclar huevos con queso',
        ),
        ElaborationStepDto(stepNumber: 3, description: 'Freír la panceta'),
        ElaborationStepDto(
          stepNumber: 4,
          description: 'Mezclar todo cuando la pasta esté lista',
        ),
      ],
    ),
  };

  @override
  Future<List<RecipeCardDto>> searchRecipes({
    String? category,
    int? maxTime,
  }) async {
    if (shouldFail) {
      throw Exception(errorMsg ?? 'Failed to fetch recipes');
    }
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    var results = _mockRecipes;

    if (category != null) {
      results = results.where((r) => r.category == category).toList();
    }

    if (maxTime != null) {
      results = results.where((r) => r.preparationTime <= maxTime).toList();
    }

    return results;
  }

  @override
  Future<RecipeDetailDto> getRecipeDetail(int id) async {

     if (shouldFail) {
      throw Exception(errorMsg ?? 'Failed to create recipe');
    }
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    final detail = _mockDetails[id];
    if (detail == null) {
      throw Exception('Receta no encontrada');
    }
    return detail;
  }

  @override
  Future<String> uploadRecipeImage(String imagePath) async {
    // Simular delay de carga
    if (shouldFail) {
      throw Exception(errorMsg ?? 'Failed to upload image');
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    return 'https://cloudinary.example.com/uploaded_image.jpg';
  }

  @override
  Future<void> createRecipe(RecipeCreateDto recipe) async {
    if (shouldFail) {
      throw Exception(errorMsg ?? 'Failed to create recipe');
    }
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulamos éxito - en un test real podríamos lanzar una excepción
  }

  @override
  Future<List<RecipeCardDto>> getMyRecipes() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRecipes
        .where((r) => r.id <= 2)
        .toList(); // Simulamos que el usuario tiene 2 recetas
  }

  @override
  Future<void> deleteRecipe(int id) async {
    if (shouldFail) {
      throw Exception(errorMsg ?? 'Failed to delete recipe');
    }
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulamos éxito
  }

  @override
  Future<RecipeDetailDto> updateRecipe(int id, RecipeCreateDto recipe) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    final detail = _mockDetails[id];
    if (detail == null) {
      throw Exception('Receta no encontrada');
    }
    return detail;
  }
}

/// Fake ApiClient para testing
/// Devuelve datos simulados sin hacer llamadas HTTP reales
class FakeApiClient extends ApiClient {

  @override
  Future<Map<String, dynamic>> getJsonObject(Uri url) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true};
  }

  @override
  Future<List<dynamic>> getJsonList(Uri url) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }
}