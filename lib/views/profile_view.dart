import 'package:flutter/material.dart';
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              
              // AVATAR CON BOTÓN DE EDITAR 
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor, 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[100]!, width: 3),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Consumer<ProfileViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      Text(
                        viewModel.fullName, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                shadowColor: Colors.black12,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _buildOptionTile(
                      context: context, 
                      icon: Icons.person_outline,
                      iconColor: Colors.blue, 
                      bgColor: Colors.blue.withOpacity(0.1),
                      title: 'Editar Perfil'
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 20, color: Colors.black12), 
                    _buildOptionTile(
                      context: context, 
                      icon: Icons.settings_outlined, 
                      iconColor: Colors.purple, 
                      bgColor: Colors.purple.withOpacity(0.1),
                      title: 'Ajustes'
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 20, color: Colors.black12),
                    _buildOptionTile(
                      context: context, 
                      icon: Icons.help_outline, 
                      iconColor: Theme.of(context).primaryColor, 
                      bgColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      title: 'Ayuda y Soporte'
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
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    shadowColor: Colors.black12,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await context.read<ProfileViewModel>().logout();
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
    required String title
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title no está disponible en esta versión.')),
        );
      },
    );
  }
}