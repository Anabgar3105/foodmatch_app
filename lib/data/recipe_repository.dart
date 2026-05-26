/// Repository for recipe-related API operations.
///
/// Handles fetching, creating, updating, and deleting recipes.
/// Provides methods for searching, retrieving details, and managing user recipes.
library;
import '../models/recipe.dart';
import 'api_client.dart';

/// Repository for recipe API calls.
class RecipeRepository {
  /// API client instance
  final ApiClient api;

  /// API host and port
  final String authority = '10.0.2.2:8080';

  /// Base API path for recipe endpoints
  final String basePath = '/api/recipes';

  /// Creates a [RecipeRepository] instance.
  ///
  /// Parameters:
  ///   - [api]: The API client to use for requests
  RecipeRepository(this.api);

  /// Searches for recipes with optional filters.
  ///
  /// Parameters:
  ///   - [category]: Optional category filter (ENTRANTES, PLATOS_COMPLETOS, SNACKS, POSTRES)
  ///   - [maxTime]: Optional maximum preparation time in minutes
  ///
  /// Returns: List of [RecipeCardDto] matching the search criteria
  ///
  /// Throws: [AppError] if the request fails
  Future<List<RecipeCardDto>> searchRecipes({
    String? category,
    int? maxTime,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (category != null) {
      queryParams['category'] = category;
    }
    if (maxTime != null) {
      queryParams['maxTime'] = maxTime.toString();
    }

    final url = Uri.http(
      authority,
      '$basePath/search',
      queryParams.isNotEmpty ? queryParams : null,
    );

    final jsonList = await api.getJsonList(url);

    return jsonList
        .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches complete details for a specific recipe.
  ///
  /// Includes ingredients and preparation steps.
  ///
  /// Parameters:
  ///   - [id]: The recipe ID to fetch
  ///
  /// Returns: [RecipeDetailDto] with full recipe information
  ///
  /// Throws: [AppError] if the recipe is not found or request fails
  Future<RecipeDetailDto> getRecipeDetail(int id) async {
    final url = Uri.http(authority, '$basePath/$id');
    final response = await api.getJsonObject(url);
    return RecipeDetailDto.fromJson(response);
  }

  /// Uploads a recipe image to cloud storage.
  ///
  /// Sends the image file to Cloudinary for storage and optimization.
  ///
  /// Parameters:
  ///   - [imagePath]: Local file path to the image
  ///
  /// Returns: URL of the uploaded image on Cloudinary
  ///
  /// Throws: [AppError] if upload fails
  // Sube la imagen y devuelve la URL de Cloudinary
  Future<String> uploadRecipeImage(String imagePath) async {
    final url = Uri.http(authority, '/api/media/upload');
    return await api.uploadImage(url, imagePath);
  }

  /// Creates a new recipe.
  ///
  /// Parameters:
  ///   - [recipe]: [RecipeCreateDto] containing recipe data
  ///
  /// Throws: [AppError] if creation fails
  Future<void> createRecipe(RecipeCreateDto recipe) async {
    final url = Uri.http(authority, basePath);
    await api.postJsonObject(url, recipe.toJson());
  }

  /// Fetches all recipes created by the current user.
  ///
  /// Returns: List of user's recipes as [RecipeCardDto]
  ///
  /// Throws: [AppError] if the request fails or user is not authenticated
  Future<List<RecipeCardDto>> getMyRecipes() async {
    final url = Uri.http(authority, '$basePath/my-recipes');
    final jsonList = await api.getJsonList(url);

    return jsonList
        .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Deletes a recipe by ID.
  ///
  /// Parameters:
  ///   - [id]: The recipe ID to delete
  ///
  /// Throws: [AppError] if deletion fails or user lacks permission
  Future<void> deleteRecipe(int id) async {
    final url = Uri.http(authority, '$basePath/$id');
    await api.delete(url);
  }

  /// Updates an existing recipe.
  ///
  /// Parameters:
  ///   - [id]: The recipe ID to update
  ///   - [recipe]: [RecipeCreateDto] containing updated recipe data
  ///
  /// Returns: Updated [RecipeDetailDto]
  ///
  /// Throws: [AppError] if update fails or user lacks permission
  Future<RecipeDetailDto> updateRecipe(int id, RecipeCreateDto recipe) async {
    final url = Uri.http(authority, '$basePath/$id');
    final response = await api.putJsonObject(url, recipe.toJson());
    return RecipeDetailDto.fromJson(response);
  }
}
