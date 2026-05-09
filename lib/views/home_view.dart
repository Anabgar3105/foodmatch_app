import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodMatch'),
        centerTitle: true,
        backgroundColor:Theme.of(context).primaryColor, 

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Text(
                '¡Hola! ¿Qué te apetece comer hoy?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
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
                    icon: Icons.soup_kitchen_outlined,
                    backendCategory: 'ENTRANTES',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Snacks',
                    icon: Icons.eco_outlined,
                    backendCategory: 'SNACKS',
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Platos Completos',
                    icon: Icons.restaurant_outlined,
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
  }

  // Widget reutilizable para las tarjetas de categoría
  Widget _buildCategoryCard(BuildContext context, {
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
          // TO-DO: Navegar a la pantalla de la ruleta/swipe pasando 'backendCategory' como argumento
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Buscando categoría: $backendCategory...')),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Theme.of(context).primaryColor, 
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}