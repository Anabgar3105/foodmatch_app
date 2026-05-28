import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/models/recipe.dart';
import 'package:foodmatch_app/viewmodels/favorites_viewmodel.dart';
import 'package:foodmatch_app/viewmodels/recipe_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String? initialTitle;
  final String? initialImage;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.initialTitle,
    this.initialImage,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _wasEdited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeDetailViewModel>().fetchRecipeDetail(widget.recipeId);
    });
  }

  // Helper para asegurar que usamos la URL optimizada que ya está en caché
  String _getOptimizedUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=Sin+Imagen';
    }
    if (url.contains('cloudinary.com') && !url.contains('q_auto')) {
      return url.replaceFirst('/upload/', '/upload/q_auto,f_auto,w_600/');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeDetailViewModel>(
        builder: (context, viewModel, child) {
          final recipe = viewModel.recipe;

          final displayTitle = recipe?.title ?? widget.initialTitle ?? '';
          final displayImage =
              recipe?.optimizedImage ?? _getOptimizedUrl(widget.initialImage);

          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () =>
                          Navigator.of(context).pop(_wasEdited ? true : null),
                    ),
                    expandedHeight: 340.0,
                    pinned: true,
                    centerTitle: false,
                    backgroundColor: Theme.of(context).primaryColor,
                    actions: [
                      // Botón de editar
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            if (recipe != null) {
                              final ingredients = recipe.ingredients
                                  .map(
                                    (i) => {
                                      'name': i.name,
                                      'quantity': i.quantity,
                                    },
                                  )
                                  .toList();
                              final steps = recipe.elaborationSteps
                                  .map((s) => s.description)
                                  .toList();

                              final updatedRecipe =
                                  await Navigator.of(context).pushNamed(
                                        '/add-recipe',
                                        arguments: {
                                          'recipeToEdit': recipe,
                                          'ingredients': ingredients,
                                          'steps': steps,
                                          'recipeId': widget.recipeId,
                                        },
                                      )
                                      as RecipeDetailDto?;

                              // Si se retornó una receta actualizada
                              if (updatedRecipe != null && context.mounted) {
                                // Limpiar caché de la imagen anterior si cambió
                                if (recipe.image != updatedRecipe.image) {
                                  await CachedNetworkImage.evictFromCache(
                                    recipe.image ?? '',
                                  );
                                }

                                if(!context.mounted) return;
                                // Actualizar la receta en el viewmodel
                                context
                                    .read<RecipeDetailViewModel>()
                                    .updateRecipeFromEdit(updatedRecipe);

                                // Actualizar la receta en favoritas si está ahí
                                context
                                    .read<FavoritesViewModel>()
                                    .updateFavoriteRecipe(widget.recipeId);

                                // Marcar que fue editada
                                setState(() {
                                  _wasEdited = true;
                                });
                              }
                            }
                          },
                        ),
                      ),
                      Consumer<RecipeViewModel>(
                        builder: (context, recipeVm, _) {
                          final isFav = recipeVm.isFavorite(widget.recipeId);
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
                              onPressed: () async {
                                final success = await recipeVm.toggleFavorite(
                                  widget.recipeId,
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
                                          '¡${recipe!.title} guardada!',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error al actualizar favoritos',
                                      ),
                                    ),
                                  );
                                }
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
                          final bool isCollapsed =
                              constraints.maxHeight <=
                              (kToolbarHeight +
                                  MediaQuery.of(context).padding.top +
                                  10);
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              left: isCollapsed ? 56 : 16,
                              bottom: 12,
                              right: isCollapsed ? 128 : 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTitle,
                                  textAlign: TextAlign.left,
                                  maxLines: isCollapsed ? 1 : 4,
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
                                if (!isCollapsed && recipe != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        Icons.timer_outlined,
                                        '${recipe.preparationTime} min',
                                        Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha:0.1),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildInfoChip(
                                        Icons.restaurant_menu,
                                        recipe.formatedCategory,
                                        Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha:0.1),
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
                          CachedNetworkImage(
                            imageUrl: displayImage,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha:0.1),
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                            placeholder: (context, url) => Container(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha:0.1),
                            ),
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
                        tabs: const [
                          Tab(text: 'Ingredientes'),
                          Tab(text: 'Preparación'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: viewModel.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : viewModel.errorMessage != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(viewModel.errorMessage!)))
                  : recipe == null
                  ? const SizedBox.shrink()
                  : TabBarView(
                      children: [
                        // PESTAÑA 1: Ingredientes
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(ing.quantity),
                            );
                          },
                        ),
                        // PESTAÑA 2: Pasos
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                          itemCount: recipe.elaborationSteps.length,
                          itemBuilder: (context, index) {
                            final step = recipe.elaborationSteps[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      '${step.stepNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
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
      color: color ?? Color(0xFFFF7A59).withValues(alpha: 0.1),
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
