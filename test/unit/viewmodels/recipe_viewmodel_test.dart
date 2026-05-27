import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import '../../fakes/fake_recipe_repository.dart';
import '../../fakes/fake_favorite_repository.dart';

void main() {
  late RecipeViewModel viewModel;
  late FakeRecipeRepository fakeRecipeRepository;
  late FakeFavoriteRepository fakeFavoriteRepository;

  setUp(() {
    fakeRecipeRepository = FakeRecipeRepository();
    fakeFavoriteRepository = FakeFavoriteRepository();
  });

  group('RecipeViewModel', () {
    test('estado inicial debería tener isLoading=false y recipes vacía', () {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );
      expect(viewModel.isLoading, false);
      expect(viewModel.recipes, isEmpty);
      expect(viewModel.errorMessage, null);
    });

    test('fetchRecipes exitoso debería cargar recetas', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      await viewModel.fetchRecipes();

      expect(viewModel.recipes, equals(await fakeRecipeRepository.searchRecipes()));
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('fetchRecipes fallido debería establecer errorMessage', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      fakeRecipeRepository.shouldFail = true;

      await viewModel.fetchRecipes();

      expect(viewModel.recipes, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('isFavorite debería retornar true si la receta está en favoritos', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      await viewModel.fetchRecipes();

      expect(viewModel.isFavorite(1), true);
      expect(viewModel.isFavorite(999), false);
    });

    test('toggleFavorite debería agregar receta a favoritos', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      final result = await viewModel.toggleFavorite(1);

      expect(result, true);
      expect(viewModel.isFavorite(1), true);
    });

    test('toggleFavorite debería remover receta de favoritos', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );


      await viewModel.fetchRecipes();
      expect(viewModel.isFavorite(1), true);

      final result = await viewModel.toggleFavorite(1);

      expect(result, true);
      expect(viewModel.isFavorite(1), false);
    });

    test('toggleFavorite fallido debería revertir el estado', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      fakeFavoriteRepository.shouldFail = true;

      final result = await viewModel.toggleFavorite(1);

      expect(result, false);
      expect(viewModel.isFavorite(1), false);
    });

    test('fetchRecipes debería notificar listeners', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      await viewModel.fetchRecipes();

      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('updateFavoriteLocal debería actualizar estado local', () {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      expect(viewModel.isFavorite(1), false);

      viewModel.updateFavoriteLocal(1, true);
      expect(viewModel.isFavorite(1), true);

      viewModel.updateFavoriteLocal(1, false);
      expect(viewModel.isFavorite(1), false);
    });

    test('fetchRecipes con categoría debería filtrar por categoría', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );


      await viewModel.fetchRecipes(category: 'ENTRANTES');

      expect(viewModel.recipes, equals(await fakeRecipeRepository.searchRecipes(category: 'ENTRANTES')));
      expect(viewModel.recipes.length, 1);
    });

    test('fetchRecipes con maxTime debería filtrar por tiempo', () async {
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );

      await viewModel.fetchRecipes(maxTime: 30);

      expect(viewModel.recipes, equals(await fakeRecipeRepository.searchRecipes(maxTime: 30)));
    });
  });
}
