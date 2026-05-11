import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/favorites_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeDetailViewModel>().fetchRecipeDetail(widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeDetailViewModel>(
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
                  Text(viewModel.errorMessage!),
                  TextButton(
                    onPressed: () =>
                        viewModel.fetchRecipeDetail(widget.recipeId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final recipe = viewModel.recipe;
          if (recipe == null) return const SizedBox.shrink();

          // Interfaz con Imagen colapsable y pestañas
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340.0,
                    pinned: true,
                    centerTitle: false, 
                    backgroundColor: Theme.of(context).primaryColor,
                    // Botón de favoritos arriba a la derecha
                    actions: [
                      Consumer<RecipeViewModel>(
                        builder: (context, recipeVm, _) {
                          final isFav = recipeVm.isFavorite(recipe.id);
                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                recipeVm.toggleFavorite(recipe.id);
                                context
                                    .read<FavoritesViewModel>()
                                    .fetchFavorites();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false, 
                      titlePadding: EdgeInsets.zero, 
                      title: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isCollapsed =constraints.maxHeight <=
                              (kToolbarHeight + MediaQuery.of(context).padding.top + 10);
                          return Container(
                            width: double
                                .infinity, 
                            padding: EdgeInsets.only(
                              left: isCollapsed ? 56 : 16,
                              bottom: 12,
                              right: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(
                                  recipe.title,
                                  textAlign: TextAlign.left, 
                                  maxLines: isCollapsed ? 1 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        Icons.timer_outlined,
                                        '${recipe.preparationTime} min',
                                        Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildInfoChip(
                                        Icons.restaurant_menu,
                                        recipe.formatedCategory,
                                        Theme.of(context).primaryColor.withOpacity(0.1),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            recipe.image,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                Container(color: Colors.grey),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: [
                          Tab(text: 'Ingredientes'),
                          Tab(text: 'Preparación'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  // PESTAÑA 1: Ingredientes
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = recipe.ingredients[index];
                      return ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          ing.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text('${ing.quantity} ${ing.unit}'),
                      );
                    },
                  ),
                  // PESTAÑA 2: Pasos
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipe.elaborationSteps.length,
                    itemBuilder: (context, index) {
                      final step = recipe.elaborationSteps[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${step.stepNumber}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget para crear los "chips" de información
Widget _buildInfoChip(IconData icon, String label, Color? color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color ?? Color(0xFFFF7A59).withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Clase auxiliar para que el TabBar se quede pegado arriba al hacer scroll
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
