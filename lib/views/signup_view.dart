import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/signup_viewmodel.dart.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surname1Controller = TextEditingController();
  final _surname2Controller = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _surname1Controller.dispose();
    _surname2Controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<SignupViewModel>(
        builder: (context, viewModel, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Semantics(
                      label: 'Logotipo de FoodMatch',
                      child: Image.asset(
                        'assets/icon/logo.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'FoodMatch',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 32),

                    //Nombres y Apellidos
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _surname1Controller,
                            decoration: const InputDecoration(
                              labelText: 'Primer Apellido',
                            ),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _surname2Controller,
                            decoration: const InputDecoration(
                              labelText: 'Segundo Apellido',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Datos de Cuenta
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Campo obligatorio';
                        if (!v.contains('@')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon:IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                          )                       
                      ),
                      validator: (v) {
                         if (v!.isEmpty) return 'Requerida';
                          if (v.length < 8) return 'Debe tener al menos 8 caracteres';
                          if (!RegExp(r'[A-Z]').hasMatch(v)) {
                            return 'Debe contener una letra mayúscula';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(v)) {
                            return 'Debe contener una letra minúscula';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(v)) {
                            return 'Debe contener un número';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?\":{}|<>_/]').hasMatch(v)) {
                            return 'Debe contener un carácter especial';
                          }
                          return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Mensaje de Error
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final dto = UserRegistrationDto(
                                    name: _nameController.text.trim(),
                                    surname1: _surname1Controller.text.trim(),
                                    surname2:
                                        _surname2Controller.text.trim().isEmpty
                                        ? null
                                        : _surname2Controller.text.trim(),
                                    username: _usernameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );

                                  final success = await viewModel.register(dto);

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '¡Cuenta creada! Inicia sesión.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context); // Vuelve al login
                                  }
                                }
                              },
                        // Botón
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
