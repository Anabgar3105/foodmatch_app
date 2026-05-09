import '../models/recipe.dart';
import 'api_client.dart';

class RecipeRepository {
  final ApiClient api;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/recipes';

  RecipeRepository(this.api);

  Future<List<RecipeCardDto>> searchRecipes({String? category, int? maxTime}) async {
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

    return jsonList.map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>)).toList();
  }
}