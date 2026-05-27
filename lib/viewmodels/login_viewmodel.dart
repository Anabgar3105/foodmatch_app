/// ViewModel for user login.
///
/// Handles authentication and stores user data locally.
/// Manages loading state and login errors.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/app_error.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';
import '../core/error_handler.dart';

/// ViewModel for login screen.
class LoginViewModel extends ChangeNotifier {
  /// Authentication repository instance
  final AuthRepository _repository = AuthRepository(ApiClient());

  /// Whether login request is in progress
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// Whether login is in progress
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// Authenticates the user with provided credentials.
  ///
  /// Stores authentication token and user profile data in local storage
  /// for later use. Previous session token is cleared before login.
  ///
  /// Parameters:
  ///   - [username]: User's username or email
  ///   - [password]: User's password
  ///
  /// Returns: true if login succeeded, false if authentication failed
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Borramos el token anterior antes de iniciar sesión para evitar conflictos
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
      _error = e is AppError ? e : ErrorHandler.handle(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
