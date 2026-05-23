import 'package:foodmatch_app/models/recipe.dart';

import '../api_client.dart';
import '../local/app_database.dart';
import '../local/entities/recipe_entity.dart';
import '../local/entities/ingredient_entity.dart';
import '../local/entities/step_entity.dart';

/// Servicio de sincronización para mantener la BD local actualizada
class SyncService {
  final ApiClient api;
  final AppDatabase? localDb;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/recipes';
  final String favoritesPath = '/api/favorites';

  SyncService(this.api, {this.localDb});

  /// Sincroniza todas las recetas completas con la BD local
  /// Descarga: todas las recetas con ingredientes y pasos en una sola llamada
  Future<void> syncAllRecipes() async {
    if (localDb == null) return;

    try {
      print('🔄 Iniciando sincronización de todas las recetas...');
      
      // Obtener todas las recetas con detalles (ingredientes y pasos)
      final url = Uri.http(authority, basePath);
      final jsonList = await api.getJsonList(url);
      
      final recipesDetail = jsonList
          .map((json) => RecipeDetailDto.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('📥 Descargadas ${recipesDetail.length} recetas con detalles');

      // Procesar y guardar todas las recetas
      for (var detail in recipesDetail) {
        try {
          await _saveRecipeDetailToLocal(detail);
        } catch (e) {
          print('❌ Error guardando receta ${detail.id}: $e');
        }
      }

      print('✅ Sincronización de recetas completada');
    } catch (e) {
      print('❌ Error sincronizando recetas: $e');
      rethrow;
    }
  }

  /// Guarda el detalle completo de una receta en la BD local (ingredientes y pasos)
  Future<void> _saveRecipeDetailToLocal(RecipeDetailDto detail) async {
    if (localDb == null) return;

    try {
      // Guardar o actualizar receta preservando flags locales
      final existing = await localDb!.recipeDao.getRecipeById(detail.id);
      
      final recipeEntity = RecipeEntity(
        id: detail.id,
        title: detail.title,
        category: detail.category,
        preparationTime: detail.preparationTime,
        image: detail.image,
        isFavorite: existing?.isFavorite ?? false,
        isMine: existing?.isMine ?? false,
      );

      if (existing != null) {
        await localDb!.recipeDao.updateRecipe(recipeEntity);
      } else {
        await localDb!.recipeDao.insertRecipe(recipeEntity);
      }

      // Eliminar ingredientes y pasos antiguos
      await localDb!.ingredientDao.deleteIngredientsForRecipe(detail.id);
      await localDb!.stepDao.deleteStepsForRecipe(detail.id);

      // Guardar ingredientes
      final ingredients = detail.ingredients
          .map((ing) => IngredientEntity(
            recipeId: detail.id,
            name: ing.name,
            quantity: ing.quantity,
            unit: ing.unit,
          ))
          .toList();

      if (ingredients.isNotEmpty) {
        await localDb!.ingredientDao.insertIngredients(ingredients);
      }

      // Guardar pasos
      final steps = detail.elaborationSteps
          .map((step) => StepEntity(
            recipeId: detail.id,
            stepNum: step.stepNumber,
            instruction: step.description,
          ))
          .toList();

      if (steps.isNotEmpty) {
        await localDb!.stepDao.insertSteps(steps);
      }

      print('💾 Guardada receta ${detail.id}: ${detail.title}');
    } catch (e) {
      print('❌ Error guardando receta ${detail.id}: $e');
      rethrow;
    }
  }

  /// Sincroniza favoritos del servidor y actualiza BD local
  Future<void> syncFavorites() async {
    if (localDb == null) return;

    try {
      print('🔄 Sincronizando favoritos...');
      
      final url = Uri.http(authority, favoritesPath);
      final jsonList = await api.getJsonList(url);
      
      final favorites = jsonList
          .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
          .toList();

      final favoriteIds = favorites.map((r) => r.id).toSet();
      final allRecipes = await localDb!.recipeDao.getAllRecipes();

      // Actualizar estado de favoritos
      for (final recipe in allRecipes) {
        final isFavorite = favoriteIds.contains(recipe.id);
        if (recipe.isFavorite != isFavorite) {
          await localDb!.recipeDao.updateFavoriteStatus(recipe.id, isFavorite);
        }
      }

      print('✅ Sincronización de favoritos completada: ${favorites.length} favoritos');
    } catch (e) {
      print('❌ Error sincronizando favoritos: $e');
      rethrow;
    }
  }

  /// Sincronización completa: recetas + favoritos
  Future<void> performFullSync() async {
    try {
      await syncAllRecipes();
      await syncFavorites();
      print('🎉 Sincronización completa exitosa');
    } catch (e) {
      print('❌ Error en sincronización completa: $e');
      rethrow;
    }
  }
}
