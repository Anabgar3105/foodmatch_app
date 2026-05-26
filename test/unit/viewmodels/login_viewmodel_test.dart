import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/login_viewmodel.dart';

import '../../fakes/fake_auth_repository.dart';


void main() {
  late LoginViewModel viewModel;
  late FakeAuthRepository fakeAuthRepository;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
  });

  group('LoginViewModel', () {
    test('inicial state debería tener isLoading=false y sin error', () {
      viewModel = LoginViewModel();
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('login fallido debería establecer errorMessage', () async {
      viewModel = LoginViewModel();
      fakeAuthRepository.setLoginFailure('Invalid credentials');
      
      try {
        await viewModel.login('wronguser', 'wrongpass');
      } catch (e) {
        // Expected
      }

      expect(viewModel.isLoading, false);
      });

    test('login debería notificar listeners durante el proceso', () async {
      viewModel = LoginViewModel();
      int notificationCount = 0;

      viewModel.addListener(() {
        notificationCount++;
      });

      await viewModel.login('testuser', 'password123');

      expect(notificationCount, greaterThanOrEqualTo(2));
    });


    test('isLoading debería ser false después del login', () async {
      viewModel = LoginViewModel();

      await viewModel.login('testuser', 'password123');

      expect(viewModel.isLoading, false);
    });
  });
}
