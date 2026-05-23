import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'sync_service.dart';

/// Servicio que detecta cambios en la conectividad y dispara sincronización
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity;
  final SyncService? _syncService;
  
  ConnectivityService({
    Connectivity? connectivity,
    SyncService? syncService,
  })  : _connectivity = connectivity ?? Connectivity(),
        _syncService = syncService;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void init() {
    // Escuchar cambios en conectividad
    _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = !result.contains(ConnectivityResult.none);

    print('📡 Conectividad: ${_isOnline ? 'ONLINE ✅' : 'OFFLINE ❌'}');

    // Si pasó de offline a online, ejecutar sincronización
    if (!wasOnline && _isOnline) {
      print('🔄 Reconectado, iniciando sincronización...');
      _syncService?.performFullSync().catchError((e) {
        print('❌ Error en sincronización automática: $e');
      });
    }

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
