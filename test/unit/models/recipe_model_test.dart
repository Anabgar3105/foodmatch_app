import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/models/recipe.dart';

void main() {
  group('RecipeCardDto', () {
    test('fromJson debería crear una instancia válida desde JSON', () {
      
      final json = {
        'id': 1,
        'title': 'Pasta Carbonara',
        'preparationTime': 20,
        'category': 'PLATOS_COMPLETOS',
        'image': 'https://example.com/image.jpg',
      };

      
      final recipe = RecipeCardDto.fromJson(json);

      
      expect(recipe.id, 1);
      expect(recipe.title, 'Pasta Carbonara');
      expect(recipe.preparationTime, 20);
      expect(recipe.category, 'PLATOS_COMPLETOS');
      expect(recipe.image, 'https://example.com/image.jpg');
    });

    test('fromJson debería usar valores por defecto cuando falten campos', () {
      final json = {'id': 2};

      
      final recipe = RecipeCardDto.fromJson(json);

      
      expect(recipe.id, 2);
      expect(recipe.title, 'Receta sin título');
      expect(recipe.preparationTime, 0);
      expect(recipe.category, 'Sin Categoría');
      expect(recipe.image, isNull);
    });

    test(
      'formatedCategory debería devolver la categoría correcta en español',
      () {
        
        const testCases = {
          'ENTRANTES': 'Entrantes',
          'PLATOS_COMPLETOS': 'Platos Completos',
          'SNACKS': 'Snacks',
          'POSTRES': 'Postres',
        };

        for (final entry in testCases.entries) {
          
          final json = {
            'id': 1,
            'title': 'Test',
            'preparationTime': 10,
            'category': entry.key,
          };
          final recipe = RecipeCardDto.fromJson(json);

          
          expect(
            recipe.formatedCategory,
            entry.value,
            reason: 'La categoría ${entry.key} debería devolver ${entry.value}',
          );
        }
      },
    );

    test(
      'formatedCategory debería devolver la categoría sin cambios si es desconocida',
      () {
        
        final json = {
          'id': 1,
          'title': 'Test',
          'preparationTime': 10,
          'category': 'CATEGORIA_DESCONOCIDA',
        };
        final recipe = RecipeCardDto.fromJson(json);

        
        expect(recipe.formatedCategory, 'CATEGORIA_DESCONOCIDA');
      },
    );
  });

  group('IngredientDto', () {
    test('fromJson debería crear un ingrediente válido', () {
      
      final json = {'name': 'Tomate', 'quantity': '2 unidades'};

      
      final ingredient = IngredientDto.fromJson(json);

      
      expect(ingredient.name, 'Tomate');
      expect(ingredient.quantity, '2 unidades');
    });

    test('fromJson debería usar valores por defecto para campos faltantes', () {
      
      final json = <String, dynamic>{};

      
      final ingredient = IngredientDto.fromJson(json);

      
      expect(ingredient.name, '');
      expect(ingredient.quantity, '');
    });

    test('fromJson debería convertir cantidad numérica a String', () {
      
      final json = {'name': 'Harina', 'quantity': 500};

      
      final ingredient = IngredientDto.fromJson(json);

      
      expect(ingredient.quantity, '500');
    });
  });

  group('ElaborationStepDto', () {
    test('fromJson debería crear un paso de elaboración válido', () {
      
      final json = {'stepNum': 1, 'instruction': 'Calentar agua'};

      
      final step = ElaborationStepDto.fromJson(json);

      
      expect(step.stepNumber, 1);
      expect(step.description, 'Calentar agua');
    });

    test('fromJson debería usar valores por defecto para campos faltantes', () {
      
      final json = <String, dynamic>{};

      
      final step = ElaborationStepDto.fromJson(json);

      
      expect(step.stepNumber, 0);
      expect(step.description, '');
    });
  });

  group('RecipeDetailDto', () {
    test('fromJson debería crear una receta detallada válida', () {
      
      final json = {
        'id': 1,
        'title': 'Pasta Carbonara',
        'image': 'https://example.com/image.jpg',
        'category': 'PLATOS_COMPLETOS',
        'preparationTime': 30,
        'ingredients': [
          {'name': 'Pasta', 'quantity': '400g'},
          {'name': 'Huevo', 'quantity': '4 unidades'},
        ],
        'steps': [
          {'stepNum': 1, 'instruction': 'Cocinar la pasta'},
          {'stepNum': 2, 'instruction': 'Preparar la salsa'},
        ],
      };

      
      final recipe = RecipeDetailDto.fromJson(json);

      
      expect(recipe.id, 1);
      expect(recipe.title, 'Pasta Carbonara');
      expect(recipe.preparationTime, 30);
      expect(recipe.ingredients.length, 2);
      expect(recipe.elaborationSteps.length, 2);
      expect(recipe.ingredients[0].name, 'Pasta');
      expect(recipe.elaborationSteps[0].description, 'Cocinar la pasta');
    });

    test('fromJson debería manejar listas vacías de ingredientes y pasos', () {
      
      final json = {
        'id': 1,
        'title': 'Receta Vacía',
        'category': 'SNACKS',
        'preparationTime': 10,
        'ingredients': [],
        'elaborationSteps': [],
      };

      
      final recipe = RecipeDetailDto.fromJson(json);

      
      expect(recipe.ingredients.isEmpty, true);
      expect(recipe.elaborationSteps.isEmpty, true);
    });
  });
}
