import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado local para simular si las notificaciones están activas
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Carga la preferencia guardada en la memoria del móvil
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // Guarda la preferencia cuando el usuario toca el interruptor
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global del tema de la app
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDarkMode = themeViewModel.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4, 
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferencias de la App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // TARJETA DE INTERRUPTORES
              Card(
                elevation: 2,
                shadowColor: Colors.black45,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    //TEMA OSCURO
                    SwitchListTile(
                      activeThumbColor: Theme.of(context).primaryColor,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.dark_mode_outlined, color: Colors.purple),
                      ),
                      title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Cambiar la apariencia de la app', style: TextStyle(fontSize: 12)),
                      value: isDarkMode,
                      onChanged: (value) {
                        themeViewModel.toggleTheme(); 
                      },
                    ),
                    const Divider(height: 1, indent: 64, color: Colors.black12),
                    
                    // NOTIFICACIONES PUSH 
                    SwitchListTile(
                      activeThumbColor: Theme.of(context).primaryColor,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_active_outlined, color: Colors.green),
                      ),
                      title: const Text('Notificaciones Push', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Avisos de nuevas recetas', style: TextStyle(fontSize: 12)),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                'Acerca de',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              //TARJETA DE INFO 
              Card(
                elevation: 2,
                shadowColor: Colors.black45,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline, color: Colors.blue),
                  ),
                  title: const Text('Versión de FoodMatch', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}