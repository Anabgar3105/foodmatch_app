import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_favorite_repository.dart';

void main() {
  group('FavoriteRepository - Integración Ascendente', () {
    late FakeFavoriteRepository favRepository;

    setUp(() {
      favRepository = FakeFavoriteRepository();
      FakeFavoriteRepository.resetFavorites();
    });

    test('getFavorites debería devolver lista de recetas favoritas', () async {

      final favorites = await favRepository.getFavorites();

      expect(favorites, isA<List>());
      expect(favorites.isNotEmpty, true);
      expect(favorites[0].id, isNotNull);
    });

    test('addFavorite debería añadir una receta a favoritos', () async {

      const newFavoriteId = 5;
      final favoritesBefore = await favRepository.getFavorites();
      final initialLength = favoritesBefore.length;

      await favRepository.addFavorite(newFavoriteId);
      
      final favoritesAfter = await favRepository.getFavorites();
      expect(favoritesAfter.length, initialLength + 1);
      expect(favRepository.getFavoritedIds().contains(newFavoriteId), true);
    });

    test('removeFavorite debería remover una receta de favoritos', () async {

      const favoriteToRemove = 1;
      final favoritesBefore = await favRepository.getFavorites();
      final initialLength = favoritesBefore.length;

      await favRepository.removeFavorite(favoriteToRemove);

      final favoritesAfter = await favRepository.getFavorites();
      expect(favoritesAfter.length, initialLength - 1);
      expect(favRepository.getFavoritedIds().contains(favoriteToRemove), false);
    });

    test('removeFavorite debería lanzar excepción si la receta no está en favoritos',
        () async {

      const nonExistentFavorite = 99999;


      expect(
        () => favRepository.removeFavorite(nonExistentFavorite),
        throwsException,
      );
    });

    test('addFavorite debería lanzar excepción si el ID es inválido', () async {

      expect(
        () => favRepository.addFavorite(-1),
        throwsException,
      );
    });
  });

  group('FavoriteRepository - Recuperación de Errores', () {
    late FakeFavoriteRepository favRepository;

    setUp(() {
      favRepository = FakeFavoriteRepository();
      FakeFavoriteRepository.resetFavorites();
    });

    test('addFavorite simulado con delay debería completarse exitosamente',
        () async {

      const recipeId = 10;
      final stopwatch = Stopwatch()..start();

      await favRepository.addFavorite(recipeId);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds >= 300, true,
          reason: 'Debería tener un delay simulado');
      expect(favRepository.getFavoritedIds().contains(recipeId), true);
    });

    test('removeFavorite con error debería permitir reintento', () async {

      const validFavorite = 1;

      expect(
        () => favRepository.removeFavorite(99999),
        throwsException,
      );

      await favRepository.removeFavorite(validFavorite);

      expect(favRepository.getFavoritedIds().contains(validFavorite), false);
    });

    test(
        'Multiple operaciones en secuencia debería mantener consistencia del estado',
        () async {

      const recipeA = 10;
      const recipeB = 11;
      const recipeC = 12;

      await favRepository.addFavorite(recipeA);
      await favRepository.addFavorite(recipeB);
      await favRepository.addFavorite(recipeC);

      var favorites = await favRepository.getFavorites();
      var initialCount = favorites.length;

      await favRepository.removeFavorite(recipeB);

      favorites = await favRepository.getFavorites();
      var countAfterRemove = favorites.length;

      expect(countAfterRemove, initialCount - 1);
      expect(favRepository.getFavoritedIds().contains(recipeA), true);
      expect(favRepository.getFavoritedIds().contains(recipeB), false);
      expect(favRepository.getFavoritedIds().contains(recipeC), true);
    });

    test('Estado debería recuperarse correctamente después de reset', () async {

      await favRepository.addFavorite(100);
      expect(favRepository.getFavoritedIds().length, greaterThan(2));

      FakeFavoriteRepository.resetFavorites();

      expect(favRepository.getFavoritedIds().length, 2);
      expect(favRepository.getFavoritedIds().contains(1), true);
      expect(favRepository.getFavoritedIds().contains(2), true);
    });
  });

  group('FavoriteRepository - Regresión', () {
    late FakeFavoriteRepository favRepository;

    setUp(() {
      favRepository = FakeFavoriteRepository();
      FakeFavoriteRepository.resetFavorites();
    });

    test('Favoritos anteriormente añadidos debería seguir siendo accesibles',
        () async {

      final initialIds = favRepository.getFavoritedIds().toList();

      await favRepository.addFavorite(20);

      for (final id in initialIds) {
        expect(favRepository.getFavoritedIds().contains(id), true,
            reason:
                'La receta $id que era favorita debería seguir siendo favorita');
      }
    });

    test('Remover un favorito no debería afectar a otros', () async {

      const favoriteToRemove = 1;
      const favoriteToKeep = 2;

      await favRepository.removeFavorite(favoriteToRemove);

      
      expect(favRepository.getFavoritedIds().contains(favoriteToRemove), false);
      expect(favRepository.getFavoritedIds().contains(favoriteToKeep), true);
    });
  });
}
