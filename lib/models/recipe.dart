class RecipeCardDto {
  final int id;
  final String title;
  final int preparationTime;
  final String category;
  final String? image; // Puede ser null si no subiste imagen

  RecipeCardDto({
    required this.id,
    required this.title,
    required this.preparationTime,
    required this.category,
    this.image,
  });

  // Factory para convertir el JSON del backend a nuestro objeto Dart
  factory RecipeCardDto.fromJson(Map<String, dynamic> json) {
    return RecipeCardDto(
      id: json['id'],
      title: json['title'],
      preparationTime: json['preparationTime'],
      category: json['category'],
      image: json['image'],
    );
  }
}