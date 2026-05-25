import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/favorites_viewmodel.dart';
import '../../fakes/fake_favorite_repository.dart';
import '../../fakes/fake_recipe_repository.dart';

void main() {
  late FavoritesViewModel viewModel;
  late FakeFavoriteRepository fakeFavoriteRepository;
  late FakeRecipeRepository fakeRecipeRepository;

  setUp(() {
    fakeFavoriteRepository = FakeFavoriteRepository();
    fakeRecipeRepository = FakeRecipeRepository();
  });

  group('FavoritesViewModel', () {
    test('estado inicial debería tener isLoading=false y favorites vacía', () {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );
      expect(viewModel.isLoading, false);
      expect(viewModel.favorites, isEmpty);
      expect(viewModel.errorMessage, null);
    });

    test('fetchFavorites exitoso debería cargar favoritos', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );


      await viewModel.fetchFavorites();

      expect(viewModel.favorites, equals(await fakeFavoriteRepository.getFavorites()));
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('fetchFavorites fallido debería establecer errorMessage', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      fakeFavoriteRepository.shouldFail = true;

      await viewModel.fetchFavorites();

      expect(viewModel.favorites, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNotNull);
    });


    test('removeFavorite debería eliminar receta de la lista', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      await viewModel.fetchFavorites();
      expect(viewModel.favorites.length, equals(2));

      await viewModel.removeFavorite(1);

      expect(viewModel.favorites.length, equals(1));
      expect(viewModel.favorites[0].id, equals(2));
    });

    test('removeFavorite con ID inválido no debería afectar la lista', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      FakeFavoriteRepository.resetFavorites();

      await viewModel.fetchFavorites();
      expect(viewModel.favorites.length, equals(2));

      await viewModel.removeFavorite(999);

      expect(viewModel.favorites.length, equals(2));
    });

    test('fetchFavorites debería notificar listeners', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      FakeFavoriteRepository.resetFavorites();

      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });


      await viewModel.fetchFavorites();

      expect(notificationCount, greaterThanOrEqualTo(1));
    });

    test('removeFavorite debería notificar listeners', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      await viewModel.fetchFavorites();
      notificationCount = 0;

      await viewModel.removeFavorite(1);

      expect(notificationCount, greaterThanOrEqualTo(1));
    });

    test('fetchFavorites debería establecer isLoading correctamente', () async {
      viewModel = FavoritesViewModel(
        repository: fakeFavoriteRepository,
        recipeRepository: fakeRecipeRepository,
      );

      expect(viewModel.isLoading, false);
      
      final future = viewModel.fetchFavorites();
      
      await future;
      expect(viewModel.isLoading, false);
    });
  });
}
