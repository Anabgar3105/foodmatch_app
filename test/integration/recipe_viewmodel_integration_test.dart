import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import '../fakes/fake_recipe_repository.dart';
import '../fakes/fake_favorite_repository.dart';

void main() {
  group('RecipeViewModel - Integración', () {
    late RecipeViewModel viewModel;
    late FakeRecipeRepository fakeRecipeRepository;
    late FakeFavoriteRepository fakeFavoriteRepository;

    setUp(() {
      fakeRecipeRepository = FakeRecipeRepository();
      fakeFavoriteRepository = FakeFavoriteRepository();
      viewModel = RecipeViewModel(
        repository: fakeRecipeRepository,
        favoriteRepository: fakeFavoriteRepository,
      );
    });

    test('fetchRecipes debería cargar todas las recetas sin filtros', () async {
      
      await viewModel.fetchRecipes();

      
      expect(viewModel.recipes.isNotEmpty, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });

    test(
      'fetchRecipes debería mostrar isLoading = true mientras carga',
      () async {
        
        bool wasLoadingDuringFetch = false;
        viewModel.addListener(() {
          if (viewModel.isLoading) {
            wasLoadingDuringFetch = true;
          }
        });

        final future = viewModel.fetchRecipes();
        expect(viewModel.isLoading, true);

        await future;

        
        expect(wasLoadingDuringFetch, true);
        expect(viewModel.isLoading, false);
      },
    );

    test('fetchRecipes debería filtrar por categoría', () async {
      
      await viewModel.fetchRecipes(category: 'PLATOS_COMPLETOS');

      
      expect(viewModel.recipes.isNotEmpty, true);
      for (final recipe in viewModel.recipes) {
        expect(recipe.category, 'PLATOS_COMPLETOS');
      }
    });

    test(
      'fetchRecipes debería filtrar por tiempo máximo de preparación',
      () async {
        await viewModel.fetchRecipes(maxTime: 15);

        
        for (final recipe in viewModel.recipes) {
          expect(
            recipe.preparationTime <= 15,
            true,
            reason:
                '${recipe.title} tiene ${recipe.preparationTime} minutos pero el máximo es 15',
          );
        }
      },
    );

    test('fetchRecipes debería aplicar múltiples filtros a la vez', () async {
      
      await viewModel.fetchRecipes(category: 'POSTRES', maxTime: 40);

      
      for (final recipe in viewModel.recipes) {
        expect(recipe.category, 'POSTRES');
        expect(recipe.preparationTime <= 40, true);
      }
    });

    test('isFavorite debería devolver true para recetas favoritas', () async {
      
      await viewModel.fetchRecipes();

      
      expect(viewModel.isFavorite(1), true);
      expect(viewModel.isFavorite(2), true);
      expect(viewModel.isFavorite(3), false);
    });

    test('toggleFavorite debería añadir una receta a favoritos', () async {
      
      const recipeId = 3;
      expect(viewModel.isFavorite(recipeId), false);

      
      final result = await viewModel.toggleFavorite(recipeId);

      
      expect(result, true);
      expect(viewModel.isFavorite(recipeId), true);
    });

    test('toggleFavorite debería remover una receta de favoritos', () async {
      const recipeId = 1;
      await viewModel.fetchRecipes(); 
      expect(viewModel.isFavorite(recipeId), true);

      final result = await viewModel.toggleFavorite(recipeId);

      expect(result, true);
      expect(viewModel.isFavorite(recipeId), false);
    });


    test(
      'fetchMyRecipes debería cargar las recetas del usuario actual',
      () async {
        await viewModel.fetchMyRecipes();

        
        expect(viewModel.myRecipes.isNotEmpty, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
      },
    );

    test(
      'deleteRecipe debería remover la receta de myRecipes y recipes',
      () async {
        
        await viewModel.fetchMyRecipes();
        await viewModel.fetchRecipes();
        final initialCount = viewModel.myRecipes.length;
        final recipeToDelete = viewModel.myRecipes.first.id;

        final result = await viewModel.deleteRecipe(recipeToDelete);

        expect(result, true);
        expect(viewModel.myRecipes.length, initialCount - 1);
        expect(viewModel.myRecipes.any((r) => r.id == recipeToDelete), false);
      },
    );

    test('deleteRecipe debería devolver false si falla', () async {
      
      fakeRecipeRepository.shouldFail = true;

      
      final result = await viewModel.deleteRecipe(1);

      
      expect(result, false);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('updateFavoriteLocal debería actualizar el estado local sin API', () {
      const recipeId = 1;

      viewModel.updateFavoriteLocal(recipeId, false);

      expect(viewModel.isFavorite(recipeId), false);

      viewModel.updateFavoriteLocal(recipeId, true);

      expect(viewModel.isFavorite(recipeId), true);
    });
  });
}
