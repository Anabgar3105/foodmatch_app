import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';
import '../models/user.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  SignupViewModel({AuthRepository? repository}) 
      : _repository = repository ?? AuthRepository(ApiClient());

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(UserRegistrationDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(dto);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}