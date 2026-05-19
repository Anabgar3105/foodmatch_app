import '../models/recipe.dart';
import 'api_client.dart';

class RecipeRepository {
  final ApiClient api;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/recipes';

  RecipeRepository(this.api);

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

  Future<RecipeDetailDto> getRecipeDetail(int id) async {
    final url = Uri.http(authority, '$basePath/$id');
    final response = await api.getJsonObject(url);
    return RecipeDetailDto.fromJson(response);
  }

  // Sube la imagen y devuelve la URL de Cloudinary
  Future<String> uploadRecipeImage(String imagePath) async {
    final url = Uri.http(authority, '/api/media/upload');
    return await api.uploadImage(url, imagePath);
  }

  Future<void> createRecipe(RecipeCreateDto recipe) async {
    final url = Uri.http(authority, basePath);
    await api.postJsonObject(url, recipe.toJson());
  }

  Future<List<RecipeCardDto>> getMyRecipes() async {
    final url = Uri.http(authority, '$basePath/my-recipes');
    final jsonList = await api.getJsonList(url);

    return jsonList
        .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteRecipe(int id) async {
    final url = Uri.http(authority, '$basePath/$id');
    await api.delete(url);
  }

  Future<RecipeDetailDto> updateRecipe(int id, RecipeCreateDto recipe) async {
    final url = Uri.http(authority, '$basePath/$id');
    final response = await api.putJsonObject(url, recipe.toJson());
    return RecipeDetailDto.fromJson(response);
  }


  
}
