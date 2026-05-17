import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/add_recipe_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedCategory = 'PLATOS_COMPLETOS';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _ingredients = [];
  final List<String> _steps = [];

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Abre la galería del dispositivo
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Dialog para añadir/editar un ingrediente
  void _showIngredientDialog({
    int? index,
    Map<String, String>? currentIngredient,
  }) {
    final nameCtrl = TextEditingController(
      text: currentIngredient?['name'] ?? '',
    );
    final qtyCtrl = TextEditingController(
      text: currentIngredient?['quantity'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          index == null ? 'Nuevo Ingrediente' : 'Editar Ingrediente',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej. Tomate)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(
                labelText: 'Cantidad (ej. 200g, Al gusto)',
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      setState(() {
                        if (index == null) {
                          // MODO CREAR
                          _ingredients.add({
                            'name': nameCtrl.text,
                            'quantity': qtyCtrl.text,
                          });
                        } else {
                          // MODO EDITAR
                          _ingredients[index] = {
                            'name': nameCtrl.text,
                            'quantity': qtyCtrl.text,
                          };
                        }
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(index == null ? 'Añadir' : 'Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog para añadir/editar un paso de elaboración
  void _showStepDialog({int? index, String? currentStep}) {
    final stepCtrl = TextEditingController(text: currentStep ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          index == null ? 'Nuevo Paso' : 'Editar Paso',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: stepCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Explica qué hay que hacer...',
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (stepCtrl.text.isNotEmpty) {
                      setState(() {
                        if (index == null) {
                          _steps.add(stepCtrl.text);
                        } else {
                          _steps[index] = stepCtrl.text;
                        }
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(index == null ? 'Añadir' : 'Guardar'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Receta'),
        // centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        shadowColor: Colors.black45,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          children: [
            //  SELECTOR DE IMAGEN
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Toca para añadir una foto',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // DATOS BÁSICOS
            Text(
              'Datos Básicos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la receta',
                prefixIcon: Icon(Icons.restaurant),
              ),
              validator: (v) => v!.isEmpty ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo (min)',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: const [
                      DropdownMenuItem(
                        value: 'ENTRANTES',
                        child: Text('Entrantes'),
                      ),
                      DropdownMenuItem(
                        value: 'PLATOS_COMPLETOS',
                        child: Text('Principales'),
                      ),
                      DropdownMenuItem(value: 'SNACKS', child: Text('Snacks')),
                      DropdownMenuItem(
                        value: 'POSTRES',
                        child: Text('Postres'),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // INGREDIENTES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingredientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  iconSize: 32,
                  onPressed: () => _showIngredientDialog(),
                ),
              ],
            ),
            if (_ingredients.isEmpty)
              const Text(
                'Aún no has añadido ingredientes.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ..._ingredients.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, String> ing = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  ing['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${ing['quantity']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                      onPressed: () => _showIngredientDialog(
                        index: idx,
                        currentIngredient: ing,
                      ), // Editamos
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(
                        () => _ingredients.removeAt(idx),
                      ), // Borramos
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // PASOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preparación',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  iconSize: 32,
                  onPressed: () => _showStepDialog(),
                ),
              ],
            ),
            if (_steps.isEmpty)
              const Text(
                'Aún no has añadido pasos.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ..._steps.asMap().entries.map((entry) {
              int idx = entry.key;
              String step = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(step),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                      onPressed: () => _showStepDialog(
                        index: idx,
                        currentStep: step,
                      ), // Editamos
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          setState(() => _steps.removeAt(idx)), // Borramos
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),

            //BOTÓN DE ENVIAR
            Consumer<AddRecipeViewModel>(
              builder: (context, viewModel, child) {
                return ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_ingredients.isEmpty ||
                                _steps.isEmpty ||
                                _imageFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, añade una foto, ingredientes y pasos.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final success = await viewModel.saveRecipe(
                              title: _titleController.text.trim(),
                              time: int.parse(_timeController.text.trim()),
                              category: _selectedCategory,
                              imagePath: _imageFile!.path,
                              ingredients: _ingredients,
                              steps: _steps,
                            );

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Receta creada con éxito!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Limpiamos el formulario reseteando la pantalla
                              Navigator.pushReplacementNamed(context, '/main');
                            } else if (viewModel.errorMessage != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Receta',
                          style: TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
