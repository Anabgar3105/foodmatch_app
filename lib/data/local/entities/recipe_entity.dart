import 'package:floor/floor.dart';

@entity
class RecipeEntity {
  @primaryKey
  final int id;

  final String title;
  final String category;
  final int preparationTime;
  final String? image;
  final bool isFavorite;
  final bool isMine;

  RecipeEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.preparationTime,
    this.image,
    this.isFavorite = false,
    this.isMine = false,
  });
}
