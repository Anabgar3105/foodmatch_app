import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/add_recipe_viewmodel.dart';
import '../../fakes/fake_recipe_repository.dart';

void main() {
  late AddRecipeViewModel viewModel;
  late FakeRecipeRepository fakeRecipeRepository;

  setUp(() {
    fakeRecipeRepository = FakeRecipeRepository();
  });

  group('AddRecipeViewModel', () {
    test('estado inicial debería tener isLoading=false y recipe=null', () {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);
      expect(viewModel.isLoading, false);
      expect(viewModel.recipe, null);
      expect(viewModel.errorMessage, null);
    });

    test('saveRecipe exitoso debería retornar true', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      final result = await viewModel.saveRecipe(
        title: 'New Recipe',
        time: 30,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [
          {'name': 'Flour', 'quantity': '500g'},
        ],
        steps: [
          'Mix ingredients',
          'Bake for 30 minutes',
        ],
      );

      expect(result, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('saveRecipe fallido debería retornar false y establecer errorMessage',
        () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);
      fakeRecipeRepository.shouldFail = true;
      fakeRecipeRepository.errorMsg = 'Error al subir imagen';

      final result = await viewModel.saveRecipe(
        title: 'New Recipe',
        time: 30,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [],
        steps: [],
      );

      expect(result, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, contains('Algo salió mal. Intenta de nuevo más tarde.'));
    });

    test('saveRecipe debería notificar listeners', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      fakeRecipeRepository.shouldFail = false;

      await viewModel.saveRecipe(
        title: 'New Recipe',
        time: 30,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [],
        steps: [],
      );

      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('saveRecipe debería establecer isLoading correctamente', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      expect(viewModel.isLoading, false);

      fakeRecipeRepository.shouldFail = false;

      await viewModel.saveRecipe(
        title: 'New Recipe',
        time: 45,
        category: 'dessert',
        imagePath: '/path/to/image.jpg',
        ingredients: [
          {'name': 'Sugar', 'quantity': '200g'},
        ],
        steps: ['Mix', 'Bake'],
      );

      expect(viewModel.isLoading, false);
    });

    test('saveRecipe debería limpiar errorMessage en nuevo intento', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      // Primer intento fallido
      fakeRecipeRepository.shouldFail = true;
      await viewModel.saveRecipe(
        title: 'Recipe 1',
        time: 30,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [],
        steps: [],
      );
      expect(viewModel.errorMessage, isNotNull);

      // Segundo intento exitoso
      fakeRecipeRepository.shouldFail = false;
      await viewModel.saveRecipe(
        title: 'Recipe 2',
        time: 30,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [],
        steps: [],
      );
      expect(viewModel.errorMessage, null);
    });

    test('saveRecipe con múltiples ingredientes debería funcionar', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      fakeRecipeRepository.shouldFail = false;

      final result = await viewModel.saveRecipe(
        title: 'Complex Recipe',
        time: 60,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [
          {'name': 'Pasta', 'quantity': '400g'},
          {'name': 'Tomato Sauce', 'quantity': '500ml'},
          {'name': 'Garlic', 'quantity': '3 cloves'},
          {'name': 'Olive Oil', 'quantity': '2 tbsp'},
        ],
        steps: [
          'Boil water',
          'Cook pasta',
          'Prepare sauce',
          'Mix and serve',
        ],
      );

      expect(result, true);
      expect(viewModel.isLoading, false);
    });

    test('saveRecipe con diferentes categorías debería funcionar', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      fakeRecipeRepository.shouldFail = false;

      final categories = ['appetizer', 'main', 'dessert', 'drink'];

      for (final category in categories) {
        final result = await viewModel.saveRecipe(
          title: 'Recipe in $category',
          time: 30,
          category: category,
          imagePath: '/path/to/image.jpg',
          ingredients: [],
          steps: [],
        );

        expect(result, true);
      }
    });

    test('saveRecipe debería manejar timeouts de forma correcta', () async {
      viewModel = AddRecipeViewModel(repository: fakeRecipeRepository);

      fakeRecipeRepository.shouldFail = true;
      fakeRecipeRepository.errorMsg = 'Timeout';

      final result = await viewModel.saveRecipe(
        title: 'Slow Recipe',
        time: 120,
        category: 'main',
        imagePath: '/path/to/image.jpg',
        ingredients: [],
        steps: [],
      );

      expect(result, false);
      expect(viewModel.errorMessage, contains('Algo salió mal. Intenta de nuevo más tarde.'));
    });
  });
}
