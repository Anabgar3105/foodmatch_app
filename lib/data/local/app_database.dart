import 'package:floor/floor.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'entities/recipe_entity.dart';
import 'entities/ingredient_entity.dart';
import 'entities/step_entity.dart';
import 'dao/recipe_dao.dart';
import 'dao/ingredient_dao.dart';
import 'dao/step_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [RecipeEntity, IngredientEntity, StepEntity])
abstract class AppDatabase extends FloorDatabase {
  RecipeDao get recipeDao;
  IngredientDao get ingredientDao;
  StepDao get stepDao;
}
