import 'package:foodmatch_app/data/api_client.dart';
import 'package:foodmatch_app/data/auth_repository.dart';
import 'package:foodmatch_app/models/user.dart';

/// Fake Repository para Auth testing
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(FakeApiClientAuth());

  bool shouldFail = false;
  String errorMsg = '';

  void setLoginFailure(String message) {
    shouldFail = true;
    errorMsg = message;
  }

  /// Resetea el estado para el siguiente test
  void reset() {
    shouldFail = false;
    errorMsg = '';
  }

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
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'success': true};
  }

  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
