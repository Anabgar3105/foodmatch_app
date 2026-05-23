import 'package:flutter/material.dart';
import 'package:foodmatch_app/data/services/sync_service.dart';
import 'package:provider/provider.dart';

/// Widget que inicializa la sincronización cuando la app se carga
/// Se ejecuta solo una vez por sesión
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _syncInitiated = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    // Ejecutar sincronización inicial con delay para evitar bloqueos
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_syncInitiated) {
        _syncInitiated = true;
        _performInitialSync();
      }
    });
  }

  void _performInitialSync() {
    try {
      final syncService = context.read<SyncService>();
      print('🚀 Iniciando sincronización automática de la app...');
      
      // Ejecutar en background sin esperar
      syncService.performFullSync().then((_) {
        print('✅ Sincronización inicial completada');
      }).catchError((e) {
        print('⚠️ Sincronización inicial falló (continuando offline): $e');
        // No mostrar error aquí, la app funciona offline
      });
    } catch (e) {
      print('⚠️ Error inicializando sincronización: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
