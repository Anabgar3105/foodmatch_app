/// Fake favorite repository for unit testing.
///
/// Provides mock favorite functionality without making real API calls.
/// Maintains mock favorite list and allows tests to control success/failure.
/// Simulates network delays.
///
/// Usage:
/// ```dart
/// final fakeRepo = FakeFavoriteRepository();
/// await fakeRepo.addFavorite(1);
/// final favorites = await fakeRepo.getFavorites();
/// expect(favorites.length, greaterThan(0));
/// ```
library;
import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/favorite_repository.dart';
import 'package:foodmatch_app/models/recipe.dart';

/// Fake repository for testing favorite operations.
class FakeFavoriteRepository extends FavoriteRepository {
  /// Creates a fake favorite repository with mock API client.
  FakeFavoriteRepository() : super(FakeApiClientFavorite());

  /// Controls whether operations should fail
  bool shouldFail = false;

  static final Set<int> _favoritedIds = {1, 2};


  // Mock recipes para devolver
  static final Map<int, RecipeCardDto> _mockFavorites = {
    1: RecipeCardDto(
      id: 1,
      title: 'Pasta Carbonara',
      preparationTime: 20,
      category: 'PLATOS_COMPLETOS',
      image: 'https://example.com/carbonara.jpg',
    ),
    2: RecipeCardDto(
      id: 2,
      title: 'Ensalada César',
      preparationTime: 10,
      category: 'ENTRANTES',
      image: 'https://example.com/caesar.jpg',
    ),
  };

  @override
  Future<void> addFavorite(int recipeId) async {
    if (shouldFail) {
      throw Exception('Failed to fetch favorites');
    }
    await Future.delayed(const Duration(milliseconds: 300));

    if (recipeId <= 0) {
      throw Exception('ID de receta inválido');
    }

    _favoritedIds.add(recipeId);
  }

  @override
  Future<List<RecipeCardDto>> getFavorites() async {
    if (shouldFail) {
      throw Exception('Failed to fetch favorites');
    }
    await Future.delayed(const Duration(milliseconds: 400));

    return _favoritedIds
        .map((id) => _mockFavorites[id] ?? _createMockRecipe(id))
        .toList();
  }

  @override
  Future<void> removeFavorite(int recipeId) async {
    if (shouldFail) {
      throw Exception('Failed to fetch favorites');
    }
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_favoritedIds.contains(recipeId)) {
      throw Exception('Receta no encontrada en favoritos');
    }

    _favoritedIds.remove(recipeId);
  }

  static RecipeCardDto _createMockRecipe(int id) {
    return RecipeCardDto(
      id: id,
      title: 'Receta $id',
      preparationTime: 15,
      category: 'PLATOS_COMPLETOS',
      image: null,
    );
  }

  static void resetFavorites() {
    _favoritedIds.clear();
    _favoritedIds.addAll({1, 2});
  }

  Set<int> getFavoritedIds() => _favoritedIds;
}

class FakeApiClientFavorite extends ApiClient {
  @override
  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<dynamic>> getJsonList(Uri url) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  @override
  Future<void> delete(Uri url) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

// Fake FavoriteRepository para testing
// class FakeFavoriteRepository extends FavoriteRepository {
//   List<RecipeCardDto> mockFavorites = [];
//   bool shouldFail = false;

//   FakeFavoriteRepository() : super(FakeApiClientFavorite());

//   @override
//   Future<List<RecipeCardDto>> getFavorites() async {
//     if (shouldFail) {
//       throw Exception('Failed to fetch favorites');
//     }
//     return mockFavorites;
//   }

//   @override
//   Future<void> removeFavorite(int id) async {
//     if (shouldFail) {
//       throw Exception('Failed to remove favorite');
//     }
//     mockFavorites.removeWhere((recipe) => recipe.id == id);
//   }

//   @override
//   Future<void> addFavorite(int id) async {
//     if (shouldFail) {
//       throw Exception('Failed to add favorite');
//     }
//   }
// }
