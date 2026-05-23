import 'package:floor/floor.dart';
import '../entities/ingredient_entity.dart';

@dao
abstract class IngredientDao {
  @insert
  Future<void> insertIngredient(IngredientEntity ingredient);

  @insert
  Future<void> insertIngredients(List<IngredientEntity> ingredients);

  @delete
  Future<void> deleteIngredient(IngredientEntity ingredient);

  @Query('DELETE FROM ingredients WHERE recipeId = :recipeId')
  Future<void> deleteIngredientsForRecipe(int recipeId);

  @Query('SELECT * FROM ingredients WHERE recipeId = :recipeId ORDER BY id')
  Future<List<IngredientEntity>> getIngredientsForRecipe(int recipeId);

  @Query('DELETE FROM ingredients')
  Future<void> deleteAllIngredients();
}
