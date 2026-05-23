import 'package:floor/floor.dart';
import '../entities/step_entity.dart';

@dao
abstract class StepDao {
  @insert
  Future<void> insertStep(StepEntity step);

  @insert
  Future<void> insertSteps(List<StepEntity> steps);

  @delete
  Future<void> deleteStep(StepEntity step);

  @Query('DELETE FROM steps WHERE recipeId = :recipeId')
  Future<void> deleteStepsForRecipe(int recipeId);

  @Query('SELECT * FROM steps WHERE recipeId = :recipeId ORDER BY stepNum')
  Future<List<StepEntity>> getStepsForRecipe(int recipeId);

  @Query('DELETE FROM steps')
  Future<void> deleteAllSteps();
}
