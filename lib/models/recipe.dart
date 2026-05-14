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
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Receta sin título',
      preparationTime: json['preparationTime'] ?? 0,
      category: json['category'] ?? 'Sin Categoría',
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

  IngredientDto({
    required this.name,
    required this.quantity,
    required this.unit,
  });

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
  final String? image;
  final String category;
  final int preparationTime;
  final List<IngredientDto> ingredients;
  final List<ElaborationStepDto> elaborationSteps;

  RecipeDetailDto({
    required this.id,
    required this.title,
    this.image,
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

  String get optimizedImage {
    if (image == null || image!.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=Sin+Imagen';
    }
    // Si es de Cloudinary, le inyectamos los parámetros de optimización
    if (image!.contains('cloudinary.com') && !image!.contains('q_auto')) {
      return image!.replaceFirst('/upload/', '/upload/q_auto,f_auto,w_600/');
    }
    return image!;
  }

  factory RecipeDetailDto.fromJson(Map<String, dynamic> json) {
    return RecipeDetailDto(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ??'',
      category: json['category'] ?? '',
      preparationTime: json['preparationTime'] ?? 0,
      ingredients:
          (json['ingredients'] as List?)
              ?.map((i) => IngredientDto.fromJson(i))
              .toList() ??
          [],
      elaborationSteps:
          (json['steps'] as List?)
              ?.map((e) => ElaborationStepDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}
