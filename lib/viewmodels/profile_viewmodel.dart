/// ViewModel for managing user profile information.
///
/// Handles loading and updating user profile data including
/// avatar image, username, email, and full name.
/// Persists profile information locally.
///
/// Extends [ChangeNotifier] for reactive state management with Provider.
library;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api_client.dart';
import '../models/user.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// ViewModel for user profile management.
class ProfileViewModel extends ChangeNotifier {
  /// Current username
  String _username = 'Cargando...';

  /// Current email
  String _email = '';

  /// Current full name
  String _fullName = '';

  /// Current avatar URL
  String? _avatarUrl;

  /// Whether profile is currently being loaded/updated
  bool _isLoading = false;

  /// Current error, if any
  AppError? _error;

  /// Current username
  String get username => _username;

  /// Current email
  String get email => _email;

  /// Current full name
  String get fullName => _fullName;

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Current error, if any
  AppError? get error => _error;

  /// User-friendly error message
  String? get errorMessage => _error?.userMessage;

  /// Optimized avatar URL with Cloudinary transformations
  String? get avatarUrl {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) return null;

    String finalUrl = _avatarUrl!;

    if (finalUrl.contains('cloudinary.com') && !finalUrl.contains('q_auto')) {
      finalUrl = finalUrl.replaceFirst(
        '/upload/',
        '/upload/q_auto,f_auto,w_200,c_fill/',
      );
    }

    return finalUrl;
  }

  final ApiClient _apiClient = ApiClient();
  final String baseUrl = 'http://10.0.2.2:8080/api';

  /// Loads profile information from local storage.
  ///
  /// Retrieves user data previously saved during login or profile update.
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('auth_username') ?? 'Chef FoodMatch';
    _email = prefs.getString('auth_email') ?? 'usuario@foodmatch.com';
    _fullName = prefs.getString('auth_full_name') ?? 'Chef FoodMatch';
    _avatarUrl = prefs.getString('auth_avatar');

    notifyListeners();
  }

  /// Updates user profile with new information.
  ///
  /// Uploads new avatar image if provided, then sends profile update to backend.
  /// Updates local storage and authentication token.
  ///
  /// Parameters:
  ///   - [newUsername]: Updated username
  ///   - [newEmail]: Updated email address
  ///   - [localImagePath]: New avatar image file path (optional)
  ///   - [removeAvatar]: If true, removes the current avatar
  ///
  /// Returns: true if update succeeded, false otherwise
  Future<bool> updateUserProfile(
    String newUsername,
    String newEmail,
    String? localImagePath, {
    bool removeAvatar = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? finalAvatarUrl = _avatarUrl;

      if (removeAvatar) {
        finalAvatarUrl = null;
      } else if (localImagePath != null) {
        final uploadUri = Uri.parse('$baseUrl/media/upload?folder=avatars');
        finalAvatarUrl = await _apiClient.uploadImage(
          uploadUri,
          localImagePath,
        );
      }

      final updateDto = UserUpdateDto(
        username: newUsername,
        email: newEmail,
        avatarUrl: finalAvatarUrl,
      );

      final profileUri = Uri.parse('$baseUrl/users/profile');
      final responseMap = await _apiClient.putJsonObject(
        profileUri,
        updateDto.toJson(),
      );
      final updatedUser = UserResponseDto.fromJson(responseMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', updatedUser.token);
      await prefs.setString('auth_username', updatedUser.username);
      await prefs.setString('auth_email', updatedUser.email);

      if (updatedUser.avatarUrl != null) {
        await prefs.setString('auth_avatar', updatedUser.avatarUrl!);
      } else {
        await prefs.remove('auth_avatar');
      }

      _username = updatedUser.username;
      _email = updatedUser.email;
      _avatarUrl = updatedUser.avatarUrl;

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

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/users/password');
      final payload = PasswordChangeDto(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ).toJson();

      await _apiClient.putJsonObject(url, payload);
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
