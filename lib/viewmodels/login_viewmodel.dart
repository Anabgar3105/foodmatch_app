import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Bprramos el token anterior antes de iniciar sesión para evitar conflictos
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      final loginData = UserLoginDto(username: username, password: password);
      final user = await _repository.login(loginData);

      await prefs.setString('auth_token', user.token);
      await prefs.setString('auth_username', user.username);
      await prefs.setString('auth_email', user.email);
      await prefs.setString(
        'auth_full_name',
        '${user.name} ${user.surname1}${user.surname2 != null ? ' ${user.surname2}' : ''}',
      );

      if (user.avatarUrl != null) {
        await prefs.setString('auth_avatar', user.avatarUrl!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
