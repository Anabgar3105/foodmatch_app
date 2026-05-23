import '../models/recipe.dart';
import 'api_client.dart';
import 'local/app_database.dart';
import 'local/entities/recipe_entity.dart';
import 'local/entities/ingredient_entity.dart';
import 'local/entities/step_entity.dart';

class RecipeRepository {
  final ApiClient api;
  final AppDatabase? localDb;
  final String authority = '10.0.2.2:8080';
  final String basePath = '/api/recipes';

  RecipeRepository(this.api, {this.localDb});

  Future<List<RecipeCardDto>> searchRecipes({
    String? category,
    int? maxTime,
  }) async {
    try {
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
      final recipes = jsonList
          .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Guardar en BD local
      await _syncRecipesToLocal(recipes);

      return recipes;
    } catch (e) {
      // Fallback a BD local si hay error de conexión
      return _getRecipesFromLocal(category: category, maxTime: maxTime);
    }
  }

  /// Sincroniza recetas de la API con la BD local
  Future<void> _syncRecipesToLocal(List<RecipeCardDto> recipes) async {
    if (localDb == null) return;
    
    final entities = recipes
        .map((r) => RecipeEntity(
          id: r.id,
          title: r.title,
          category: r.category,
          preparationTime: r.preparationTime,
          image: r.image,
        ))
        .toList();

    // Insertar o actualizar recetas (ignorar si ya existe)
    for (final entity in entities) {
      final existing = await localDb!.recipeDao.getRecipeById(entity.id);
      if (existing != null) {
        // Actualizar pero preservar isFavorite e isMine
        await localDb!.recipeDao.updateRecipe(
          RecipeEntity(
            id: entity.id,
            title: entity.title,
            category: entity.category,
            preparationTime: entity.preparationTime,
            image: entity.image,
            isFavorite: existing.isFavorite,
            isMine: existing.isMine,
          ),
        );
      } else {
        await localDb!.recipeDao.insertRecipe(entity);
      }
    }
  }

  /// Obtiene recetas de la BD local con filtros
  Future<List<RecipeCardDto>> _getRecipesFromLocal({
    String? category,
    int? maxTime,
  }) async {
    if (localDb == null) return [];

    List<RecipeEntity> entities;

    if (category != null && maxTime != null) {
      entities = await localDb!.recipeDao
          .getRecipesByCategoryAndTime(category, maxTime);
    } else if (category != null) {
      entities = await localDb!.recipeDao.getRecipesByCategory(category);
    } else if (maxTime != null) {
      entities = await localDb!.recipeDao.getRecipesByMaxTime(maxTime);
    } else {
      entities = await localDb!.recipeDao.getAllRecipes();
    }

    return entities
        .map((e) => RecipeCardDto(
          id: e.id,
          title: e.title,
          category: e.category,
          preparationTime: e.preparationTime,
          image: e.image,
        ))
        .toList();
  }

  Future<RecipeDetailDto> getRecipeDetail(int id) async {
    try {
      final url = Uri.http(authority, '$basePath/$id');
      final response = await api.getJsonObject(url);
      final detail = RecipeDetailDto.fromJson(response);
      
      // Guardar en BD local
      await _syncRecipeDetailToLocal(detail);
      
      return detail;
    } catch (e) {
      // Fallback a BD local si hay error de conexión
      print('Error obteniendo receta desde API, buscando en BD local: $e');
      final localDetail = await getRecipeDetailFromLocal(id);
      if (localDetail != null) {
        return localDetail;
      }
      rethrow;
    }
  }

  /// Obtiene la receta completa desde la BD local (con ingredientes y pasos)
  Future<RecipeDetailDto?> getRecipeDetailFromLocal(int recipeId) async {
    if (localDb == null) return null;

    try {
      final recipe = await localDb!.recipeDao.getRecipeById(recipeId);
      if (recipe == null) return null;

      final ingredients = await localDb!.ingredientDao.getIngredientsForRecipe(recipeId);
      final steps = await localDb!.stepDao.getStepsForRecipe(recipeId);

      return RecipeDetailDto(
        id: recipe.id,
        title: recipe.title,
        image: recipe.image,
        category: recipe.category,
        preparationTime: recipe.preparationTime,
        ingredients: ingredients
            .map((i) => IngredientDto(
              name: i.name,
              quantity: i.quantity,
              unit: i.unit,
            ))
            .toList(),
        elaborationSteps: steps
            .map((s) => ElaborationStepDto(
              stepNumber: s.stepNum,
              description: s.instruction,
            ))
            .toList(),
      );
    } catch (e) {
      print('Error obteniendo receta local: $e');
      return null;
    }
  }

  /// Sincroniza detalles de receta con BD local
  Future<void> _syncRecipeDetailToLocal(RecipeDetailDto detail) async {
    if (localDb == null) return;

    // Actualizar receta
    final recipeEntity = RecipeEntity(
      id: detail.id,
      title: detail.title,
      category: detail.category,
      preparationTime: detail.preparationTime,
      image: detail.image,
    );

    final existing = await localDb!.recipeDao.getRecipeById(detail.id);
    if (existing != null) {
      await localDb!.recipeDao.updateRecipe(
        RecipeEntity(
          id: recipeEntity.id,
          title: recipeEntity.title,
          category: recipeEntity.category,
          preparationTime: recipeEntity.preparationTime,
          image: recipeEntity.image,
          isFavorite: existing.isFavorite,
          isMine: existing.isMine,
        ),
      );
    } else {
      await localDb!.recipeDao.insertRecipe(recipeEntity);
    }

    // Guardar ingredientes y pasos
    await localDb!.ingredientDao.deleteIngredientsForRecipe(detail.id);
    await localDb!.stepDao.deleteStepsForRecipe(detail.id);

    final ingredients = detail.ingredients
        .map((i) => IngredientEntity(
          recipeId: detail.id,
          name: i.name,
          quantity: i.quantity,
          unit: i.unit,
        ))
        .toList();

    final steps = detail.elaborationSteps
        .map((s) => StepEntity(
          recipeId: detail.id,
          stepNum: s.stepNumber,
          instruction: s.description,
        ))
        .toList();

    if (ingredients.isNotEmpty) {
      await localDb!.ingredientDao.insertIngredients(ingredients);
    }
    if (steps.isNotEmpty) {
      await localDb!.stepDao.insertSteps(steps);
    }
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
    try {
      final url = Uri.http(authority, '$basePath/my-recipes');
      final jsonList = await api.getJsonList(url);
      final recipes = jsonList
          .map((json) => RecipeCardDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Guardar en BD local y marcar como isMine
      await _syncMyRecipesToLocal(recipes);

      return recipes;
    } catch (e) {
      // Fallback a BD local
      if (localDb == null) rethrow;
      final entities = await localDb!.recipeDao.getMyRecipes();
      return entities
          .map((e) => RecipeCardDto(
            id: e.id,
            title: e.title,
            category: e.category,
            preparationTime: e.preparationTime,
            image: e.image,
          ))
          .toList();
    }
  }

  /// Sincroniza mis recetas y las marca como isMine
  Future<void> _syncMyRecipesToLocal(List<RecipeCardDto> recipes) async {
    if (localDb == null) return;

    final entities = recipes
        .map((r) => RecipeEntity(
          id: r.id,
          title: r.title,
          category: r.category,
          preparationTime: r.preparationTime,
          image: r.image,
          isMine: true,
        ))
        .toList();

    for (final entity in entities) {
      final existing = await localDb!.recipeDao.getRecipeById(entity.id);
      if (existing != null) {
        await localDb!.recipeDao.updateRecipe(
          RecipeEntity(
            id: entity.id,
            title: entity.title,
            category: entity.category,
            preparationTime: entity.preparationTime,
            image: entity.image,
            isFavorite: existing.isFavorite,
            isMine: true,
          ),
        );
      } else {
        await localDb!.recipeDao.insertRecipe(entity);
      }
    }
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

  /// Marca una receta como favorita en la BD local
  Future<void> markFavoriteLocally(int recipeId) async {
    if (localDb == null) return;
    await localDb!.recipeDao.updateFavoriteStatus(recipeId, true);
  }

  /// Desmarca una receta de favoritos en la BD local
  Future<void> unmarkFavoriteLocally(int recipeId) async {
    if (localDb == null) return;
    await localDb!.recipeDao.updateFavoriteStatus(recipeId, false);
  }

  /// Obtiene favoritos de la BD local
  Future<List<RecipeCardDto>> getFavoritesFromLocal() async {
    if (localDb == null) return [];
    final entities = await localDb!.recipeDao.getFavorites();
    return entities
        .map((e) => RecipeCardDto(
          id: e.id,
          title: e.title,
          category: e.category,
          preparationTime: e.preparationTime,
          image: e.image,
        ))
        .toList();
  }

  /// Obtiene todas las recetas almacenadas localmente
  Future<List<RecipeCardDto>> getAllRecipesFromLocal() async {
    if (localDb == null) return [];
    return _getRecipesFromLocal();
  }

  /// Obtiene el conteo total de recetas en la BD local
  Future<int> getLocalRecipeCount() async {
    if (localDb == null) return 0;
    final recipes = await localDb!.recipeDao.getAllRecipes();
    return recipes.length;
  }
  
}

