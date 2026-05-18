import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _removeAvatar = false;

  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profileVM = context.read<ProfileViewModel>();
    _usernameController = TextEditingController(text: profileVM.username);
    _emailController = TextEditingController(text: profileVM.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _localImagePath = pickedFile.path;
        _removeAvatar = false;
      });
    }
  }

  // Orquesta la subida llamando al ViewModel
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileVM = context.read<ProfileViewModel>();

      final success = await profileVM.updateUserProfile(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _localImagePath,
        removeAvatar: _removeAvatar,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileVM.errorMessage ?? 'Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        shadowColor: Colors.black45,
      ),
      body: profileVM.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AVATAR INTERACTIVO
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _removeAvatar ? null : (_localImagePath != null
                                    ? FileImage(File(_localImagePath!)) as ImageProvider
                                    : (profileVM.avatarUrl != null && profileVM.avatarUrl!.isNotEmpty)
                                        ? CachedNetworkImageProvider(profileVM.avatarUrl!)
                                        : null),
                                child: (_removeAvatar || (_localImagePath == null && (profileVM.avatarUrl == null || profileVM.avatarUrl!.isEmpty)))
                                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                                    : null,
                              ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),                     
                        ],
                      ),
                    ),
                   if (!_removeAvatar && (_localImagePath != null || (profileVM.avatarUrl != null && profileVM.avatarUrl!.isNotEmpty)))
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              _localImagePath = null;
                              _removeAvatar = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Quitar foto de perfil',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),

                    // CAMPO NOMBRE DE USUARIO
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'El nombre no puede estar vacío'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // CAMPO EMAIL
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'El correo no puede estar vacío';
                        if (!value.contains('@'))
                          return 'Formato de correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN DE GUARDAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
