import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/models/user.dart';

void main() {
  group('UserLoginDto', () {
    test('toJson debería devolver el mapa correcto', () {

      final login = UserLoginDto(
        username: 'usuario123',
        password: 'miPassword',
      );

      final json = login.toJson();

      expect(json['username'], 'usuario123');
      expect(json['password'], 'miPassword');
    });
  });

  group('UserResponseDto', () {
    test('fromJson debería crear un usuario válido con todos los campos', () {

      final json = {
        'id': 1,
        'username': 'usuario123',
        'email': 'usuario@example.com',
        'token': 'token_secreto',
        'name': 'Juan',
        'surname1': 'Pérez',
        'surname2': 'López',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final user = UserResponseDto.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'usuario123');
      expect(user.email, 'usuario@example.com');
      expect(user.token, 'token_secreto');
      expect(user.name, 'Juan');
      expect(user.surname1, 'Pérez');
      expect(user.surname2, 'López');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('fromJson debería usar valores por defecto cuando falten campos', () {
      final json = {
        'id': 2,
        'username': 'usuario456',
        'email': 'usuario456@example.com',
        'name': 'María',
        'surname1': 'González',
      };

      final user = UserResponseDto.fromJson(json);

      expect(user.token, ''); 
      expect(user.surname2, isNull);
      expect(user.avatarUrl, isNull);
    });
  });

  group('UserRegistrationDto', () {
    test('toJson debería devolver el mapa correcto', () {

      final registration = UserRegistrationDto(
        name: 'Juan',
        surname1: 'Pérez',
        surname2: 'López',
        email: 'juan@example.com',
        username: 'juanperez',
        password: 'miPassword123',
      );

      final json = registration.toJson();

      expect(json['name'], 'Juan');
      expect(json['surname1'], 'Pérez');
      expect(json['surname2'], 'López');
      expect(json['email'], 'juan@example.com');
      expect(json['username'], 'juanperez');
      expect(json['password'], 'miPassword123');
    });

    test('toJson debería permitir surname2 nulo', () {

      final registration = UserRegistrationDto(
        name: 'María',
        surname1: 'García',
        email: 'maria@example.com',
        username: 'mariagarcia',
        password: 'password123',
      );

      final json = registration.toJson();

      expect(json['surname2'], isNull);
    });
  });

  group('UserUpdateDto', () {
    test('toJson debería devolver el mapa correcto', () {
      final update = UserUpdateDto(
        username: 'nuevoUsername',
        email: 'nuevo@example.com',
        avatarUrl: 'https://example.com/new-avatar.jpg',
      );

      final json = update.toJson();

      expect(json['username'], 'nuevoUsername');
      expect(json['email'], 'nuevo@example.com');
      expect(json['avatarUrl'], 'https://example.com/new-avatar.jpg');
    });

    test('toJson debería permitir avatarUrl nulo', () {
      final update = UserUpdateDto(
        username: 'usuario',
        email: 'usuario@example.com',
      );

      final json = update.toJson();

      expect(json['avatarUrl'], isNull);
    });
  });

  group('PasswordChangeDto', () {
    test('toJson debería devolver el mapa correcto', () {
      final passwordChange = PasswordChangeDto(
        currentPassword: 'passwordActual',
        newPassword: 'passwordNueva',
      );

      final json = passwordChange.toJson();

      expect(json['currentPassword'], 'passwordActual');
      expect(json['newPassword'], 'passwordNueva');
    });
  });
}
