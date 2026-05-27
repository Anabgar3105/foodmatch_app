/// Fake authentication repository for unit testing.
///
/// Provides mock authentication functionality without making real API calls.
/// Simulates network delays and allows tests to control success/failure.
///
/// Usage:
/// ```dart
/// final fakeRepo = FakeAuthRepository();
/// fakeRepo.setLoginFailure('Invalid credentials');
/// expect(() => fakeRepo.login(dto), throwsException);
/// ```
library;
import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/auth_repository.dart';
import 'package:foodmatch_app/models/user.dart';

/// Fake repository for testing authentication.
class FakeAuthRepository extends AuthRepository {
  /// Creates a fake auth repository with mock API client.
  FakeAuthRepository() : super(FakeApiClientAuth());

  /// Controls whether login should fail
  bool shouldFail = false;

  /// Error message to throw when shouldFail is true
  String errorMsg = '';

  /// Configures login to fail with the given message.
  ///
  /// Parameters:
  ///   - [message]: Error message to throw
  void setLoginFailure(String message) {
    shouldFail = true;
    errorMsg = message;
  }

  /// Resets state for the next test.
  /// Clears failure flags and messages.
  void reset() {
    shouldFail = false;
    errorMsg = '';
  }

  /// Simulates user login with mock credentials.
  ///
  /// Valid credentials: 'usuario@example.com' or 'testuser'.
  /// Simulates 500ms network delay.
  ///
  /// Parameters:
  ///   - [loginDto]: Login credentials to validate
  ///
  /// Returns: Mock user response
  ///
  /// Throws: Exception if login fails or credentials are invalid
  @override
  Future<UserResponseDto> login(UserLoginDto loginDto) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    if (shouldFail) {
      shouldFail = false;
      throw Exception(errorMsg);
    }

    // Validación básica simulada
    if (loginDto.username.isEmpty || loginDto.password.isEmpty) {
      throw Exception('Usuario o contraseña vacíos');
    }

    // Simular credenciales válidas
    if (loginDto.username == 'usuario@example.com' ||
        loginDto.username == 'testuser') {
      return UserResponseDto(
        id: 1,
        username: loginDto.username,
        email: 'usuario@example.com',
        token: 'fake_token_${loginDto.username}',
        name: 'Juan',
        surname1: 'Pérez',
        surname2: 'López',
        avatarUrl: null,
      );
    }

    throw Exception('Credenciales inválidas');
  }

  @override
  Future<void> register(UserRegistrationDto dto) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    if (shouldFail) {
      shouldFail = false;
      throw Exception(errorMsg);
    }

    // Validación básica simulada
    if (dto.name.isEmpty ||
        dto.surname1.isEmpty ||
        dto.email.isEmpty ||
        dto.username.isEmpty ||
        dto.password.isEmpty) {
      throw Exception('Todos los campos son requeridos');
    }

    if (!dto.email.contains('@')) {
      throw Exception('Email inválido');
    }

    if (dto.password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    // Simulamos éxito
  }
}

class FakeApiClientAuth extends ApiClient {
  @override
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true};
  }

  @override
  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
