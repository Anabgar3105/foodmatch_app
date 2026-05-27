/// ViewModel for user registration/signup.
///
/// Handles new user account creation.
/// Manages loading state and registration errors.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';
import '../models/user.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for signup/registration screen.
class SignupViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  /// Creates a [SignupViewModel] instance.
  ///
  /// Optionally accepts custom repository instance for testing.
  SignupViewModel({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(ApiClient());

  /// Whether registration request is in progress
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// Whether registration is in progress
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// Registers a new user account.
  ///
  /// Creates the account with the provided registration data.
  /// User can then log in with the credentials provided during registration.
  ///
  /// Parameters:
  ///   - [dto]: [UserRegistrationDto] containing registration information
  ///
  /// Returns: true if registration succeeded, false if failed
  ///
  /// Throws: Sets [error] with [AppError] details if registration fails
  Future<bool> register(UserRegistrationDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.register(dto);
      return true;
    } catch (e) {
      _error = e is AppError ? e : ErrorHandler.handle(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
