import 'api_client.dart';
import '../models/recipe.dart'; 

class FavoriteRepository {
  final ApiClient api;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/favorites';

  FavoriteRepository(this.api);

  Future<void> addFavorite(int recipeId) async {
    final url = Uri.http(authority, '$basePath/$recipeId');
    await api.postVoid(url); 
  }

  Future<List<RecipeCardDto>> getFavorites() async {
    final url = Uri.http(authority, basePath);
    final jsonList = await api.getJsonList(url);
    return jsonList.map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> removeFavorite(int recipeId) async {
    final url = Uri.http(authority, '$basePath/$recipeId');
    await api.delete(url); 
  }
}