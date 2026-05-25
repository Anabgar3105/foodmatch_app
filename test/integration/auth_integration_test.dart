import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodmatch_app/models/user.dart';
import '../fakes/fake_auth_repository.dart';

void main() {
  group('AuthRepository - Integración Descendente (Top-down)', () {
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
    });

    tearDown(() {
      fakeAuthRepository.reset();
    });

    test(
      'login debería retornar UserResponseDto válido con credenciales correctas',
      () async {
        
        final loginDto = UserLoginDto(
          username: 'testuser',
          password: 'password123',
        );

        
        final result = await fakeAuthRepository.login(loginDto);

        
        expect(result, isA<UserResponseDto>());
        expect(result.username, 'testuser');
        expect(result.token, isNotEmpty);
        expect(result.email, 'usuario@example.com');
      },
    );

    test('login debería lanzar excepción con credenciales inválidas', () async {
      
      final loginDto = UserLoginDto(
        username: 'usuarioInvalido',
        password: 'wrongPassword',
      );

      expect(() => fakeAuthRepository.login(loginDto), throwsException);
    });

    test('login debería lanzar excepción si usuario está vacío', () async {
      
      final loginDto = UserLoginDto(username: '', password: 'password123');

      expect(() => fakeAuthRepository.login(loginDto), throwsException);
    });

    test('login debería lanzar excepción si contraseña está vacía', () async {
      
      final loginDto = UserLoginDto(username: 'testuser', password: '');

      expect(() => fakeAuthRepository.login(loginDto), throwsException);
    });

    test(
      'register debería completarse sin errores con datos válidos',
      () async {
        
        final registerDto = UserRegistrationDto(
          name: 'Juan',
          surname1: 'Pérez',
          surname2: 'López',
          email: 'juan@example.com',
          username: 'juanperez',
          password: 'password123',
        );

        expect(() => fakeAuthRepository.register(registerDto), returnsNormally);
      },
    );

    test('register debería lanzar excepción si email es inválido', () async {
      
      final registerDto = UserRegistrationDto(
        name: 'Juan',
        surname1: 'Pérez',
        email: 'emailInvalido',
        username: 'juanperez',
        password: 'password123',
      );

      expect(() => fakeAuthRepository.register(registerDto), throwsException);
    });

    test(
      'register debería lanzar excepción si contraseña es muy corta',
      () async {
        
        final registerDto = UserRegistrationDto(
          name: 'Juan',
          surname1: 'Pérez',
          email: 'juan@example.com',
          username: 'juanperez',
          password: 'short',
        );

        expect(() => fakeAuthRepository.register(registerDto), throwsException);
      },
    );

    test(
      'register debería lanzar excepción si campos requeridos están vacíos',
      () async {

        final registerDto = UserRegistrationDto(
          name: '',
          surname1: 'Pérez',
          email: 'juan@example.com',
          username: 'juanperez',
          password: 'password123',
        );

        expect(() => fakeAuthRepository.register(registerDto), throwsException);
      },
    );

    test(
      'login con error simulado debería lanzar excepción personalizada',
      () async {

        fakeAuthRepository.setLoginFailure('Servidor no disponible');
        final loginDto = UserLoginDto(
          username: 'testuser',
          password: 'password123',
        );

        expect(() => fakeAuthRepository.login(loginDto), throwsException);
      },
    );
  });

  group('RecuperaciónDeErrores - Test de Recuperación', () {
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      SharedPreferences.setMockInitialValues({});
    });

    test('login debería simular timeout después de cierto tiempo', () async {

      final loginDto = UserLoginDto(
        username: 'testuser',
        password: 'password123',
      );

      
      final stopwatch = Stopwatch()..start();
      await fakeAuthRepository.login(loginDto);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds >= 500, true);
    });

    test('login recuperado después de fallo debería funcionar', () async {
      fakeAuthRepository.setLoginFailure('Error temporal');
      var loginDto = UserLoginDto(
        username: 'testuser',
        password: 'password123',
      );

      await expectLater(
        () => fakeAuthRepository.login(loginDto),
        throwsException,
      );

      fakeAuthRepository.reset();
      final result = await fakeAuthRepository.login(loginDto);

      expect(result, isA<UserResponseDto>());
      expect(result.username, 'testuser');
    });
  });
}
