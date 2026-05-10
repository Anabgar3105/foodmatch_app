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
      final loginData = UserLoginDto(username: username, password: password);
      final user = await _repository.login(loginData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);

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
