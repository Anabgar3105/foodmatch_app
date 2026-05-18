import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api_client.dart';
import '../models/user.dart';

class ProfileViewModel extends ChangeNotifier {
  String _username = 'Cargando...';
  String _email = '';
  String _fullName = '';
  String? _avatarUrl; 

  bool _isLoading = false;
  String? _errorMessage;

  String get username => _username;
  String get email => _email;
  String get fullName => _fullName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get avatarUrl {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) return null;
  
    String finalUrl = _avatarUrl!;

    if (finalUrl.contains('cloudinary.com') && !finalUrl.contains('q_auto')) {
      finalUrl = finalUrl.replaceFirst('/upload/', '/upload/q_auto,f_auto,w_200,c_fill/');
    }

    return finalUrl;
  }

  final ApiClient _apiClient = ApiClient();
  final String baseUrl = 'http://10.0.2.2:8080/api'; 

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('auth_username') ?? 'Chef FoodMatch';
    _email = prefs.getString('auth_email') ?? 'usuario@foodmatch.com';
    _fullName = prefs.getString('auth_full_name') ?? 'Chef FoodMatch';
    _avatarUrl = prefs.getString('auth_avatar'); 

    notifyListeners(); 
  }

  Future<bool> updateUserProfile(String newUsername, String newEmail, String? localImagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? finalAvatarUrl = _avatarUrl; 

      if (localImagePath != null) {
        final uploadUri = Uri.parse('$baseUrl/media/upload?folder=avatars');
        finalAvatarUrl = await _apiClient.uploadImage(uploadUri, localImagePath);
      }

      final updateDto = UserUpdateDto(
        username: newUsername,
        email: newEmail,
        avatarUrl: finalAvatarUrl,
      );

      final profileUri = Uri.parse('$baseUrl/users/profile');
      final responseMap = await _apiClient.putJsonObject(profileUri, updateDto.toJson());

      final updatedUser = UserResponseDto.fromJson(responseMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', updatedUser.token); 
      await prefs.setString('auth_username', updatedUser.username);
      await prefs.setString('auth_email', updatedUser.email);
      if (updatedUser.avatarUrl != null) {
        await prefs.setString('auth_avatar', updatedUser.avatarUrl!);
      }

      _username = updatedUser.username;
      _email = updatedUser.email;
      _avatarUrl = updatedUser.avatarUrl;

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('auth_token');
    await prefs.remove('auth_username');
    await prefs.remove('auth_email');
    await prefs.remove('auth_full_name');
    await prefs.remove('auth_avatar'); 
    
    notifyListeners();
  }
}