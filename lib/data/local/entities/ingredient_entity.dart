import 'package:floor/floor.dart';
import 'recipe_entity.dart';

@Entity(
  tableName: 'ingredients',
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
class IngredientEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id; 
  
  final int recipeId; 
  final String name;
  final String quantity;
  final String unit;

  IngredientEntity({
    this.id, 
    required this.recipeId, 
    required this.name, 
    required this.quantity,
    required this.unit,
  });
}