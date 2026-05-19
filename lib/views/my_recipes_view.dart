import 'package:flutter/material.dart';
import 'package:foodmatch_app/views/add_recipe_view.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/recipe_viewmodel.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';
import '../models/recipe.dart'; // O donde tengas RecipeCardDto
import 'recipe_detail_view.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeViewModel>().fetchMyRecipes();
    });
  }

  // Optimización de Cloudinary para listas (w_300 es ideal para miniaturas)
  String _getOptimizedUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/300x300?text=Sin+Imagen';
    }
    String finalUrl = url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;
    if (finalUrl.contains('cloudinary.com') && !finalUrl.contains('q_auto')) {
      return finalUrl.replaceFirst(
        '/upload/',
        '/upload/q_auto,f_auto,w_300,c_fill/',
      );
    }
    return finalUrl;
  }

  // Diálogo de confirmación antes de borrar
  void _confirmDelete(BuildContext context, RecipeCardDto recipe) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar receta?'),
        content: Text(
          '¿Seguro que quieres borrar "${recipe.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    final recipeVM = context.read<RecipeViewModel>();

                    final success = await recipeVM.deleteRecipe(recipe.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Receta eliminada'
                              : (recipeVM.errorMessage ?? 'Error al eliminar'),
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: const Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeVM = context.watch<RecipeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recetas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: recipeVM.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : recipeVM.myRecipes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipeVM.myRecipes.length,
              itemBuilder: (context, index) {
                final recipe = recipeVM.myRecipes[index];
                return _buildRecipeCard(context, recipe);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no has subido ninguna receta.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, RecipeCardDto recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navegamos al detalle de la receta al tocar la tarjeta
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
        },
        child: Row(
          children: [
            // Imagen cuadrada en la izquierda
            SizedBox(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: _getOptimizedUrl(recipe.image),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Información en el centro
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.preparationTime} min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).hintColor,
              ),
              onPressed: () async {
                if (!context.mounted) return;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando detalles de la receta...'),
                        ],
                      ),
                    ),
                  ),
                );

                await context.read<RecipeDetailViewModel>().fetchRecipeDetail(
                  recipe.id,
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                final recipeDetail = context
                    .read<RecipeDetailViewModel>()
                    .recipe;

                if (recipeDetail != null && context.mounted) {
                  // Navegamos pasando la receta detallada al constructor
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddRecipeScreen(recipeToEdit: recipeDetail),
                    ),
                  );

                  // Si la edición fue exitosa, refrescamos la lista
                  if (result == true && context.mounted) {
                    context.read<RecipeViewModel>().fetchMyRecipes();
                  }
                }
              },
            ),
            // Botón de papelera en la derecha
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, recipe),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
