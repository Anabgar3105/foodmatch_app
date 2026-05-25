import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/models/user.dart';
import 'package:foodmatch_app/viewmodels/signup_viewmodel.dart.dart';
import '../../fakes/fake_auth_repository.dart';

void main() {
  late SignupViewModel viewModel;
  late FakeAuthRepository fakeAuthRepository;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
  });

  group('SignupViewModel', () {
    test('estado inicial debería tener isLoading=false y sin error', () {
      viewModel = SignupViewModel(repository: fakeAuthRepository);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('register exitoso debería retornar true', () async {
      viewModel = SignupViewModel(repository: fakeAuthRepository);
      fakeAuthRepository.shouldFail = false;

      final dto = UserRegistrationDto(
        username: 'newuser',
        email: 'newuser@test.com',
        password: 'password123',
        name: 'New',
        surname1: 'User',
      );

      final result = await viewModel.register(dto);

      expect(result, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('register fallido debería retornar false y establecer errorMessage', () async {
      viewModel = SignupViewModel(repository: fakeAuthRepository);
      fakeAuthRepository.shouldFail = true;
      fakeAuthRepository.errorMsg = 'Email already exists';

      final dto = UserRegistrationDto(
        username: 'existinguser',
        email: 'existing@test.com',
        password: 'password123',
        name: 'Existing',
        surname1: 'User',
      );

      final result = await viewModel.register(dto);

      expect(result, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, contains('Email already exists'));
    });

    test('register debería notificar listeners', () async {
      viewModel = SignupViewModel(repository: fakeAuthRepository);
      int notificationCount = 0;

      viewModel.addListener(() {
        notificationCount++;
      });

      final dto = UserRegistrationDto(
        username: 'testuser',
        email: 'test@test.com',
        password: 'password123',
        name: 'Test',
        surname1: 'User',
      );

      await viewModel.register(dto);

      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('errorMessage debería limpiarse al realizar un nuevo registro', () async {
      viewModel = SignupViewModel(repository: fakeAuthRepository);

      // Primer intento fallido
      fakeAuthRepository.shouldFail = true;
      fakeAuthRepository.errorMsg = 'Error 1';
      
      var dto = UserRegistrationDto(
        username: 'user1',
        email: 'user1@test.com',
        password: 'password123',
        name: 'User',
        surname1: 'One',
      );
      
      await viewModel.register(dto);
      expect(viewModel.errorMessage, isNotNull);

      // Segundo intento exitoso
      fakeAuthRepository.shouldFail = false;
      
      dto = UserRegistrationDto(
        username: 'user2',
        email: 'user2@test.com',
        password: 'password123',
        name: 'User',
        surname1: 'Two',
      );
      
      await viewModel.register(dto);
      expect(viewModel.errorMessage, null);
    });

    test('isLoading debería ser true durante el registro', () async {
      viewModel = SignupViewModel(repository: fakeAuthRepository);
      
      bool wasLoadingDuringRegister = false;
      
      viewModel.addListener(() {
        if (viewModel.isLoading) {
          wasLoadingDuringRegister = true;
        }
      });

      final dto = UserRegistrationDto(
        username: 'testuser',
        email: 'test@test.com',
        password: 'password123',
        name: 'Test',
        surname1: 'User',
      );

      await viewModel.register(dto);

      expect(viewModel.isLoading, false);
    });
  });
}
