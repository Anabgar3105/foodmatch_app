import 'api_client.dart';
import '../models/recipe.dart';
import 'local/app_database.dart';
import 'recipe_repository.dart';

class FavoriteRepository {
  final ApiClient api;
  final RecipeRepository recipeRepository;
  final AppDatabase? localDb;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/favorites';

  FavoriteRepository(this.api, this.recipeRepository, {this.localDb});

  Future<void> addFavorite(int recipeId) async {
    try {
      final url = Uri.http(authority, '$basePath/$recipeId');
      await api.postVoid(url);

      // Actualizar BD local
      await recipeRepository.markFavoriteLocally(recipeId);
    } catch (e) {
      // Si falla la API, solo actualizar localmente
      await recipeRepository.markFavoriteLocally(recipeId);
      rethrow;
    }
  }

  Future<List<RecipeCardDto>> getFavorites() async {
    try {
      final url = Uri.http(authority, basePath);
      final jsonList = await api.getJsonList(url);
      final recipes = jsonList
          .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sincronizar con BD local
      await _syncFavoritesLocally(recipes);

      return recipes;
    } catch (e) {
      // Fallback a BD local si hay error de conexión
      return await recipeRepository.getFavoritesFromLocal();
    }
  }

  /// Sincroniza favoritos con BD local
  Future<void> _syncFavoritesLocally(List<RecipeCardDto> favorites) async {
    if (localDb == null) return;

    final favoriteIds = favorites.map((r) => r.id).toSet();
    final allRecipes = await localDb!.recipeDao.getAllRecipes();

    // Actualizar estados de favoritos
    for (final recipe in allRecipes) {
      final isFavorite = favoriteIds.contains(recipe.id);
      if (recipe.isFavorite != isFavorite) {
        await localDb!.recipeDao.updateFavoriteStatus(recipe.id, isFavorite);
      }
    }
  }

  Future<void> removeFavorite(int recipeId) async {
    try {
      final url = Uri.http(authority, '$basePath/$recipeId');
      await api.delete(url);

      // Actualizar BD local
      await recipeRepository.unmarkFavoriteLocally(recipeId);
    } catch (e) {
      // Si falla la API, solo actualizar localmente
      await recipeRepository.unmarkFavoriteLocally(recipeId);
      rethrow;
    }
  }
}
