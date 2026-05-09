import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../viewmodels/recipe_viewmodel.dart';
import '../models/recipe.dart'; 

class RecipeSwipeScreen extends StatefulWidget {
  const RecipeSwipeScreen({super.key});

  @override
  State<RecipeSwipeScreen> createState() => _RecipeSwipeScreenState();
}

class _RecipeSwipeScreenState extends State<RecipeSwipeScreen> {
  bool _isInit = true;
  // Controlador para poder deslizar las tarjetas con los botones 
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final category = ModalRoute.of(context)!.settings.arguments as String;
      Future.microtask(() =>
          context.read<RecipeViewModel>().fetchRecipes(category: category));
      _isInit = false;
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
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      final category = ModalRoute.of(context)!.settings.arguments as String;
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
                      const SnackBar(content: Text('¡Has visto todas las recetas!')),
                    );
                  },
                  padding: const EdgeInsets.all(24.0),
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
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

  // Lógica al deslizar
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint('Deslizado ${direction.name}');
    if (direction == CardSwiperDirection.right) {
      // TO-DO: Llamar al backend para hacer POST en /api/favorites/{id}
      debugPrint('¡Es un Match!'); 
    }
    return true; 
  }

  // Diseño de la tarjeta individual 
  Widget _buildRecipeCard(RecipeCardDto recipe) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(recipe.image ?? 'https://content.elmueble.com/medio/2025/09/26/bocadillo-sin-pan-de-tortilla-con-jamon-queso-y-canonigos_4dc8baa9_250926121250_900x900.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
            stops: [0.5, 1.0], 
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.title,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${recipe.preparationTime} min',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String label, VoidCallback onPressed) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}