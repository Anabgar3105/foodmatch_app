/// Repository for user authentication operations.
///
/// Handles user login, registration, and token management
/// through the FoodMatch API.
library;
import '../models/user.dart';
import 'api_client.dart';

/// Repository for authentication-related API calls.
class AuthRepository {
  /// API client instance
  final ApiClient api;

  /// API base URL for authentication endpoints
  final String baseUrl = 'http://10.0.2.2:8080/api/users';

  /// Creates an [AuthRepository] instance.
  ///
  /// Parameters:
  ///   - [api]: The API client to use for requests
  AuthRepository(this.api);

  /// Authenticates a user with credentials.
  ///
  /// Parameters:
  ///   - [loginDto]: Login credentials (username and password)
  ///
  /// Returns: User response with authentication token
  ///
  /// Throws: [AppError] if authentication fails
  Future<UserResponseDto> login(UserLoginDto loginDto) async {
    final url = Uri.parse('$baseUrl/login');
    final json = await api.postJsonObject(url, loginDto.toJson());

    return UserResponseDto.fromJson(json);
  }

  /// Registers a new user account.
  ///
  /// Parameters:
  ///   - [dto]: Registration data (name, email, username, password)
  ///
  /// Throws: [AppError] if registration fails (duplicate username/email, etc.)
  Future<void> register(UserRegistrationDto dto) async {
    final url = Uri.parse('$baseUrl/signup');
    await api.postJsonObject(url, dto.toJson());
  }
}
