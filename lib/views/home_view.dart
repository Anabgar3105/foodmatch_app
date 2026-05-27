import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodMatch'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        shadowColor: Colors.black45,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '¡Hola! ¿Qué te apetece comer hoy?',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.9,
                        children: [
                          _buildCategoryCard(
                            context,
                            title: 'Entrantes',
                            icon: Icons.tapas_outlined,
                            backendCategory: 'ENTRANTES',
                          ),
                          _buildCategoryCard(
                            context,
                            title: 'Snacks',
                            icon: Icons.cookie_outlined,
                            backendCategory: 'SNACKS',
                          ),
                          _buildCategoryCard(
                            context,
                            title: 'Platos Completos',
                            icon: Icons.dinner_dining_outlined,
                            backendCategory: 'PLATOS_COMPLETOS',
                          ),
                          _buildCategoryCard(
                            context,
                            title: 'Postres',
                            icon: Icons.cake_outlined,
                            backendCategory: 'POSTRES',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget reutilizable para las tarjetas de categoría
  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String backendCategory,
  }) {
    return Semantics(
      label: 'Buscar recetas de la categoría $title',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pushNamed(context, '/recipes', arguments: backendCategory);
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
