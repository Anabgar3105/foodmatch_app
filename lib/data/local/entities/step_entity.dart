import 'package:floor/floor.dart';
import 'recipe_entity.dart';

@Entity(
  tableName: 'steps',
  foreignKeys: [
    ForeignKey(
      childColumns: ['recipeId'],
      parentColumns: ['id'],
      entity: RecipeEntity,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [Index(value: ['recipeId'])],
)
class StepEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  final int recipeId; // Vinculación a la receta
  final int stepNum;
  final String instruction;

  StepEntity({
    this.id, 
    required this.recipeId, 
    required this.stepNum, 
    required this.instruction
  });
}