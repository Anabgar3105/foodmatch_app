import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';
import '../models/user.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  SignupViewModel({AuthRepository? repository}) 
      : _repository = repository ?? AuthRepository(ApiClient());

  bool _isLoading = false;
  AppError? _error;

  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.userMessage;

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