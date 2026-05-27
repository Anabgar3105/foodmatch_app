/// Data Transfer Object for recipe card display.
///
/// Contains minimal recipe information for list views.
/// Used when displaying recipes in cards, tiles, or grids.
///
/// Properties:
/// - [id]: Unique recipe identifier
/// - [title]: Recipe name
/// - [preparationTime]: Estimated cooking time in minutes
/// - [category]: Recipe category (ENTRANTES, PLATOS_COMPLETOS, SNACKS, POSTRES)
/// - [image]: Optional image URL
class RecipeCardDto {
  /// Unique identifier for the recipe
  final int id;

  /// Recipe title/name
  final String title;

  /// Preparation time in minutes
  final int preparationTime;

  /// Recipe category enum value
  final String category;

  /// Optional image URL
  final String? image;

  /// Creates a [RecipeCardDto] instance.
  RecipeCardDto({
    required this.id,
    required this.title,
    required this.preparationTime,
    required this.category,
    this.image,
  });

  /// Creates a [RecipeCardDto] from JSON API response.
  factory RecipeCardDto.fromJson(Map<String, dynamic> json) {
    return RecipeCardDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Receta sin título',
      preparationTime: json['preparationTime'] ?? 0,
      category: json['category'] ?? 'Sin Categoría',
      image: json['image'],
    );
  }

  /// Returns the formatted category name for display.
  /// Converts API enum values to user-friendly Spanish text.
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

/// Data Transfer Object for a single ingredient.
///
/// Represents a recipe ingredient with name and quantity information.
///
/// Properties:
/// - [name]: Ingredient name (e.g., "flour", "sugar")
/// - [quantity]: Amount required (e.g., "2 cups", "500g")
class IngredientDto {
  /// Ingredient name
  final String name;

  /// Quantity required
  final String quantity;

  /// Creates an [IngredientDto] instance.
  IngredientDto({required this.name, required this.quantity});

  /// Creates an [IngredientDto] from JSON API response.
  factory IngredientDto.fromJson(Map<String, dynamic> json) {
    return IngredientDto(
      name: json['name'] ?? '',
      quantity: (json['quantity']?.toString()) ?? '',
    );
  }
}

/// Data Transfer Object for a recipe elaboration/cooking step.
///
/// Represents a single step in the recipe preparation process.
///
/// Properties:
/// - [stepNumber]: Order of the step in the recipe
/// - [description]: Instructions for this step
class ElaborationStepDto {
  /// Sequential step number (1-indexed)
  final int stepNumber;

  /// Detailed instructions for this step
  final String description;

  /// Creates an [ElaborationStepDto] instance.
  ElaborationStepDto({required this.stepNumber, required this.description});

  /// Creates an [ElaborationStepDto] from JSON API response.
  factory ElaborationStepDto.fromJson(Map<String, dynamic> json) {
    return ElaborationStepDto(
      stepNumber: json['stepNum'] ?? 0,
      description: json['instruction'] ?? '',
    );
  }
}

/// Data Transfer Object for complete recipe details.
///
/// Contains all information needed to display a recipe in detail,
/// including ingredients and preparation steps.
/// Used when fetching recipe details from the API.
///
/// Properties:
/// - [id]: Unique recipe identifier
/// - [title]: Recipe name
/// - [image]: Image URL (optimized for display)
/// - [category]: Recipe category
/// - [preparationTime]: Estimated cooking time in minutes
/// - [ingredients]: List of required ingredients
/// - [elaborationSteps]: Ordered list of preparation steps
class RecipeDetailDto {
  /// Unique recipe identifier
  final int id;

  /// Recipe title/name
  final String title;

  /// Recipe image URL
  final String? image;

  /// Recipe category enum value
  final String category;

  /// Preparation time in minutes
  final int preparationTime;

  /// List of recipe ingredients
  final List<IngredientDto> ingredients;

  /// Ordered list of preparation steps
  final List<ElaborationStepDto> elaborationSteps;

  /// Creates a [RecipeDetailDto] instance.
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

  /// Returns an optimized image URL for display.
  ///
  /// Applies Cloudinary transformations for better performance:
  /// - Auto quality (q_auto) for optimal compression
  /// - Auto format (f_auto) for best browser support
  /// - Max width 600px (w_600) for responsive design
  ///
  /// Returns a placeholder URL if no image is available.
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

  /// Creates a [RecipeDetailDto] from JSON API response.
  factory RecipeDetailDto.fromJson(Map<String, dynamic> json) {
    return RecipeDetailDto(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ?? '',
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

/// Data Transfer Object for creating or updating a recipe.
///
/// Contains all information needed to persist a recipe to the backend.
/// Used for both recipe creation and updates.
///
/// Properties:
/// - [title]: Recipe name
/// - [preparationTime]: Estimated cooking time in minutes
/// - [category]: Recipe category (enum value)
/// - [image]: Image URL
/// - [ingredients]: List of ingredients with quantities
/// - [elaborationSteps]: Ordered list of preparation step instructions
class RecipeCreateDto {
  /// Recipe title/name
  final String title;

  /// Preparation time in minutes
  final int preparationTime;

  /// Recipe category enum value
  final String category;

  /// Recipe image URL
  final String image;

  /// List of recipe ingredients (name and quantity pairs)
  final List<Map<String, dynamic>> ingredients;

  /// List of preparation steps (instructions)
  final List<Map<String, dynamic>> elaborationSteps;

  /// Creates a [RecipeCreateDto] instance.
  RecipeCreateDto({
    required this.title,
    required this.preparationTime,
    required this.category,
    required this.image,
    required this.ingredients,
    required this.elaborationSteps,
  });

  /// Converts the recipe to JSON format for API requests.
  ///
  /// Normalizes step data to use 'stepNum' and 'instruction' fields
  /// for backend compatibility, supporting both creation and update flows.
  Map<String, dynamic> toJson() => {
    'title': title,
    'preparationTime': preparationTime,
    'category': category,
    'image': image,
    'ingredients': ingredients,
    'steps': elaborationSteps.asMap().entries.map((entry) {
      final step = entry.value;
      return {
        'stepNum': entry.key + 1,
        'instruction': step['instruction'] ?? step['description'] ?? '',
      };
    }).toList(),
  };
}
