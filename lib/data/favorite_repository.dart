/// Repository for favorite/bookmark operations.
///
/// Handles adding, removing, and fetching user favorite recipes.
library;
import 'api_client.dart';
import '../models/recipe.dart';

/// Repository for favorite API calls.
class FavoriteRepository {
  /// API client instance
  final ApiClient api;

  /// API host and port
  final String authority = '10.0.2.2:8080';

  /// Base API path for favorite endpoints
  final String basePath = '/api/favorites';

  /// Creates a [FavoriteRepository] instance.
  ///
  /// Parameters:
  ///   - [api]: The API client to use for requests
  FavoriteRepository(this.api);

  /// Adds a recipe to the user's favorites.
  ///
  /// Parameters:
  ///   - [recipeId]: The ID of the recipe to add to favorites
  ///
  /// Throws: [AppError] if the operation fails or user is not authenticated
  Future<void> addFavorite(int recipeId) async {
    final url = Uri.http(authority, '$basePath/$recipeId');
    await api.postVoid(url);
  }

  /// Fetches all recipes marked as favorites by the current user.
  ///
  /// Returns: List of favorite recipes as [RecipeCardDto]
  ///
  /// Throws: [AppError] if the request fails or user is not authenticated
  Future<List<RecipeCardDto>> getFavorites() async {
    final url = Uri.http(authority, basePath);
    final jsonList = await api.getJsonList(url);
    return jsonList
        .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Removes a recipe from the user's favorites.
  ///
  /// Parameters:
  ///   - [recipeId]: The ID of the recipe to remove from favorites
  ///
  /// Throws: [AppError] if the operation fails or user is not authenticated
  Future<void> removeFavorite(int recipeId) async {
    final url = Uri.http(authority, '$basePath/$recipeId');
    await api.delete(url);
  }
}
