import 'package:floor/floor.dart';
import '../entities/recipe_entity.dart';

@dao
abstract class RecipeDao {
  @insert
  Future<void> insertRecipe(RecipeEntity recipe);

  @insert
  Future<void> insertRecipes(List<RecipeEntity> recipes);

  @update
  Future<void> updateRecipe(RecipeEntity recipe);

  @delete
  Future<void> deleteRecipe(RecipeEntity recipe);

  @Query('DELETE FROM RecipeEntity')
  Future<void> deleteAllRecipes();

  @Query('SELECT * FROM RecipeEntity WHERE id = :id')
  Future<RecipeEntity?> getRecipeById(int id);

  @Query('SELECT * FROM RecipeEntity ORDER BY title')
  Future<List<RecipeEntity>> getAllRecipes();

  @Query('SELECT * FROM RecipeEntity WHERE category = :category ORDER BY title')
  Future<List<RecipeEntity>> getRecipesByCategory(String category);

  @Query('SELECT * FROM RecipeEntity WHERE preparationTime <= :maxTime ORDER BY preparationTime')
  Future<List<RecipeEntity>> getRecipesByMaxTime(int maxTime);

  @Query('SELECT * FROM RecipeEntity WHERE category = :category AND preparationTime <= :maxTime ORDER BY preparationTime')
  Future<List<RecipeEntity>> getRecipesByCategoryAndTime(String category, int maxTime);

  @Query('SELECT * FROM RecipeEntity WHERE isFavorite = 1 ORDER BY title')
  Future<List<RecipeEntity>> getFavorites();

  @Query('SELECT * FROM RecipeEntity WHERE isMine = 1 ORDER BY title')
  Future<List<RecipeEntity>> getMyRecipes();

  @Query('UPDATE RecipeEntity SET isFavorite = :isFavorite WHERE id = :id')
  Future<void> updateFavoriteStatus(int id, bool isFavorite);

  @Query('UPDATE RecipeEntity SET isMine = :isMine WHERE id = :id')
  Future<void> updateIsMineStatus(int id, bool isMine);

  @Query('SELECT * FROM RecipeEntity WHERE title LIKE :query ORDER BY title')
  Future<List<RecipeEntity>> searchRecipesByTitle(String query);
}
