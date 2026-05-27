import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodmatch_app/viewmodels/theme_viewmodel.dart';
import 'package:foodmatch_app/views/edit_profile_view.dart';
import 'package:foodmatch_app/views/help_view.dart';
import 'package:foodmatch_app/views/my_recipes_view.dart';
import 'package:foodmatch_app/views/settings_view.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // AVATAR CON BOTÓN DE EDITAR
              Consumer<ProfileViewModel>(
                builder: (context, viewModel, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 3.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (viewModel.avatarUrl != null &&
                              viewModel.avatarUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(viewModel.avatarUrl!)
                          : null,
                      child:
                          (viewModel.avatarUrl == null ||
                              viewModel.avatarUrl!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 55,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Consumer<ProfileViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      Text(
                        viewModel.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // TARJETA DE OPCIONES
              Card(
                elevation: 2,
                shadowColor: Colors.black45,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildOptionTile(
                      context: context,
                      icon: Icons.restaurant_menu_outlined,
                      iconColor: Colors.orange,
                      bgColor: Colors.orange.withValues(alpha: 0.1),
                      title: 'Mis Recetas',
                      destination: const MyRecipesScreen(),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: Colors.black12,
                    ),

                    _buildOptionTile(
                      context: context,
                      icon: Icons.person_outline,
                      iconColor: Colors.blue,
                      bgColor: Colors.blue.withValues(alpha: 0.1),
                      title: 'Editar Perfil',
                      destination: const EditProfileScreen(),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: Colors.black12,
                    ),
                    _buildOptionTile(
                      context: context,
                      icon: Icons.settings_outlined,
                      iconColor: Colors.purple,
                      bgColor: Colors.purple.withValues(alpha: 0.1),
                      title: 'Ajustes',
                      destination: const SettingsScreen(),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: Colors.black12,
                    ),
                    _buildOptionTile(
                      context: context,
                      icon: Icons.help_outline,
                      iconColor: Theme.of(context).primaryColor,
                      bgColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      title: 'Ayuda y Soporte',
                      destination: const HelpScreen(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // BOTÓN DE LOGOUT
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Theme.of(context).cardColor,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black12,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await context.read<ProfileViewModel>().logout();
                    if (!context.mounted) return;
                    await context.read<ThemeViewModel>().resetToDefault();
                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    Widget? destination,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title no está disponible en esta versión.'),
            ),
          );
        }
      },
    );
  }
}
