class RecipeCardDto {
  final int id;
  final String title;
  final int preparationTime;
  final String category;
  final String? image; 

  RecipeCardDto({
    required this.id,
    required this.title,
    required this.preparationTime,
    required this.category,
    this.image,
  });

  factory RecipeCardDto.fromJson(Map<String, dynamic> json) {
    return RecipeCardDto(
      id: json['id'],
      title: json['title'],
      preparationTime: json['preparationTime'],
      category: json['category'],
      image: json['image'],
    );
  }

   String get formatedCategory {
    switch (category) {
      case 'ENTRANTES':
        return 'Entrantes';
      case 'PLATOS_COMPLETOS':
        return 'Platos Completos';
      case 'SNACKS':
        return 'Snacks';
      case 'POSTRES':
        return 'Postres';
      default:
        return category;
    }
  }
}

class IngredientDto {
  final String name;
  final String quantity;
  final String unit;

  IngredientDto({required this.name, required this.quantity, required this.unit});

  factory IngredientDto.fromJson(Map<String, dynamic> json) {
    return IngredientDto(
      name: json['name'] ?? '',
      quantity: (json['quantity']?.toString()) ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class ElaborationStepDto {
  final int stepNumber;
  final String description;

  ElaborationStepDto({required this.stepNumber, required this.description});

  factory ElaborationStepDto.fromJson(Map<String, dynamic> json) {
    return ElaborationStepDto(
      stepNumber: json['stepNum'] ?? 0,
      description: json['instruction'] ?? '',
    );
  }
}

class RecipeDetailDto {
  final int id;
  final String title;
  final String image;
  final String category;
  final int preparationTime;
  final List<IngredientDto> ingredients;
  final List<ElaborationStepDto> elaborationSteps;

  RecipeDetailDto({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.preparationTime,
    required this.ingredients,
    required this.elaborationSteps,
  });

  String get formatedCategory {
    switch (category) {
      case 'ENTRANTES':
        return 'Entrantes';
      case 'PLATOS_COMPLETOS':
        return 'Platos Completos';
      case 'SNACKS':
        return 'Snacks';
      case 'POSTRES':
        return 'Postres';
      default:
        return category;
    }
  }

  factory RecipeDetailDto.fromJson(Map<String, dynamic> json) {
    return RecipeDetailDto(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ?? 'https://content.elmueble.com/medio/2025/09/26/bocadillo-sin-pan-de-tortilla-con-jamon-queso-y-canonigos_4dc8baa9_250926121250_900x900.webp',
      category: json['category'] ?? '',
      preparationTime: json['preparationTime'] ?? 0,
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => IngredientDto.fromJson(i))
              .toList() ?? [],
      elaborationSteps: (json['steps'] as List?)
              ?.map((e) => ElaborationStepDto.fromJson(e))
              .toList() ?? [],
    );
  }
}