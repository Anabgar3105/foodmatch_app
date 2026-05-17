import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  String _username = 'Cargando...';
  String _email = '';
  String _fullName = '';

  String get username => _username;
  String get email => _email;
  String get fullName => _fullName;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('auth_username') ?? 'Chef FoodMatch';
    _email = prefs.getString('auth_email') ?? 'usuario@foodmatch.com';
    _fullName = prefs.getString('auth_full_name') ?? 'Chef FoodMatch';

    notifyListeners(); 
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('auth_token');
    await prefs.remove('auth_username');
    await prefs.remove('auth_email');
    
    notifyListeners();
  }
}