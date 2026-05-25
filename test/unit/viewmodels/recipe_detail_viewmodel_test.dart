import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/recipe_detail_viewmodel.dart';
import '../../fakes/fake_recipe_repository.dart';

void main() {
  late RecipeDetailViewModel viewModel;
  late FakeRecipeRepository fakeRecipeRepository;

  setUp(() {
    fakeRecipeRepository = FakeRecipeRepository();
  });

  group('RecipeDetailViewModel', () {
    test('estado inicial debería tener isLoading=false y recipe=null', () {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);
      expect(viewModel.isLoading, false);
      expect(viewModel.recipe, null);
      expect(viewModel.errorMessage, null);
    });

    test('fetchRecipeDetail exitoso debería cargar la receta', () async {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

      await viewModel.fetchRecipeDetail(1);

      expect(viewModel.recipe, equals(await fakeRecipeRepository.getRecipeDetail(1)));
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('fetchRecipeDetail fallido debería establecer errorMessage', () async {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

      fakeRecipeRepository.shouldFail = true;

      await viewModel.fetchRecipeDetail(1);

      expect(viewModel.recipe, null);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('fetchRecipeDetail debería notificar listeners', () async {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      await viewModel.fetchRecipeDetail(1);

      expect(notificationCount, greaterThanOrEqualTo(1));
    });

    test(
      'fetchRecipeDetail debería establecer isLoading correctamente',
      () async {
        viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

        expect(viewModel.isLoading, false);

        await viewModel.fetchRecipeDetail(1);

        expect(viewModel.isLoading, false);
      },
    );

    test('recipe con ingredientes debería ser accesible', () async {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

      await viewModel.fetchRecipeDetail(1);

      expect(viewModel.recipe?.ingredients.length, equals(4));
      expect(viewModel.recipe?.ingredients[0].name, equals('Pasta'));
    });

    test('recipe con pasos de elaboración debería ser accesible', () async {
      viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

      await viewModel.fetchRecipeDetail(1);

      expect(viewModel.recipe?.elaborationSteps.length, equals(4));
      expect(
        viewModel.recipe?.elaborationSteps[0].description,
        contains('Cocinar la pasta en agua salada'),
      );
    });

    test(
      'errorMessage debería limpiarse al hacer un nuevo fetchRecipeDetail',
      () async {
        viewModel = RecipeDetailViewModel(repository: fakeRecipeRepository);

        // Primer intento fallido
        fakeRecipeRepository.shouldFail = true;
        await viewModel.fetchRecipeDetail(1);
        expect(viewModel.errorMessage, isNotNull);

        // Segundo intento exitoso
        fakeRecipeRepository.shouldFail = false;
      

        await viewModel.fetchRecipeDetail(1);
        expect(viewModel.errorMessage, null);
      },
    );
  });
}
