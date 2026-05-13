import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/favorites_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../viewmodels/recipe_viewmodel.dart';
import '../models/recipe.dart';
import 'recipe_detail_view.dart';

class RecipeSwipeScreen extends StatefulWidget {
  const RecipeSwipeScreen({super.key});

  @override
  State<RecipeSwipeScreen> createState() => _RecipeSwipeScreenState();
}

class _RecipeSwipeScreenState extends State<RecipeSwipeScreen> {
  bool _isInit = true;
  bool _isFirstImageReady = false;

  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final category = ModalRoute.of(context)!.settings.arguments as String;

      Future.microtask(() {
        _loadDataAndPrecache(category);
      });

      _isInit = false;
    }
  }

  String _getOptimizedUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=Sin+Imagen';
    }
    if (url.contains('cloudinary.com') && !url.contains('q_auto')) {
      return url.replaceFirst('/upload/', '/upload/q_auto,f_auto,w_600/');
    }
    return url;
  }

  Future<void> _loadDataAndPrecache(String category) async {
    final viewModel = context.read<RecipeViewModel>();
    await viewModel.fetchRecipes(category: category);

    if (!mounted) return;

    if (viewModel.recipes.isNotEmpty) {
      final firstImageUrl = _getOptimizedUrl(viewModel.recipes.first.image);
      await precacheImage(CachedNetworkImageProvider(firstImageUrl), context);

      if (viewModel.recipes.length > 1) {
        precacheImage(
          CachedNetworkImageProvider(
            _getOptimizedUrl(viewModel.recipes[1].image),
          ),
          context,
        );
      }
      if (viewModel.recipes.length > 2) {
        precacheImage(
          CachedNetworkImageProvider(
            _getOptimizedUrl(viewModel.recipes[2].image),
          ),
          context,
        );
      }

      if (mounted) {
        setState(() {
          _isFirstImageReady = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodMatch'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Consumer<RecipeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading ||
              (viewModel.recipes.isNotEmpty && !_isFirstImageReady)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preparando recetas...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ups! ${viewModel.errorMessage}'),
                  ElevatedButton(
                    onPressed: () {
                      final category =
                          ModalRoute.of(context)!.settings.arguments as String;
                      viewModel.fetchRecipes(category: category);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.recipes.isEmpty) {
            return const Center(
              child: Text('No hay recetas disponibles en esta categoría.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: CardSwiper(
                  controller: _swiperController,
                  cardsCount: viewModel.recipes.length,
                  onSwipe: _onSwipe,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Has visto todas las recetas!'),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(24.0),
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) {
                        return _buildRecipeCard(viewModel.recipes[index]);
                      },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.close,
                      Colors.red,
                      'Descartar',
                      () => _swiperController.swipe(CardSwiperDirection.left),
                    ),
                    _buildActionButton(
                      Icons.favorite,
                      Colors.green,
                      'Me gusta',
                      () => _swiperController.swipe(CardSwiperDirection.right),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final viewModel = context.read<RecipeViewModel>();
    final recipe = viewModel.recipes[previousIndex];

    if (currentIndex != null && currentIndex + 2 < viewModel.recipes.length) {
      precacheImage(
        CachedNetworkImageProvider(
          _getOptimizedUrl(viewModel.recipes[currentIndex + 2].image),
        ),
        context,
      );
    }

    if (direction == CardSwiperDirection.right) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
            recipeId: recipe.id,
            initialTitle: recipe.title,
            initialImage: recipe.image,
          ),
        ),
      );
    } else if (direction == CardSwiperDirection.left) {
      debugPrint('Deslizado left');
    }
    return true;
  }

  // Diseño de la tarjeta individual
  Widget _buildRecipeCard(RecipeCardDto recipe) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 249, 210, 196),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _getOptimizedUrl(recipe.image),
              fit: BoxFit.contain,
            ),

            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer<RecipeViewModel>(
                        builder: (context, viewModel, child) {
                          final isFav = viewModel.isFavorite(recipe.id);

                          return Semantics(
                            label: isFav
                                ? 'Quitar de favoritos'
                                : 'Guardar en favoritos',
                            button: true,
                            child: IconButton(
                              icon: Icon(
                                isFav ? Icons.bookmark : Icons.bookmark_border,
                                color: Theme.of(context).primaryColor,
                                size: 36,
                              ),
                              onPressed: () async {
                                final success = await viewModel.toggleFavorite(
                                  recipe.id,
                                );
                                if (!context.mounted) return;

                                if (success) {
                                  context
                                      .read<FavoritesViewModel>()
                                      .fetchFavorites();
                                  if (!isFav) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '¡${recipe.title} guardada!',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error de conexión.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFF5D4037),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.preparationTime} min',
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.formatedCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String label,
    VoidCallback onPressed,
  ) {
    return Semantics(
      label: label,
      button: true,
      child: FloatingActionButton(
        heroTag: null,
        onPressed: onPressed,
        backgroundColor: Theme.of(context).cardColor,
        splashColor: color.withOpacity(0.2),
        hoverColor: color.withOpacity(0.2),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
