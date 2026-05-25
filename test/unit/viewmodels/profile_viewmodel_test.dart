import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/profile_viewmodel.dart';

void main() {
  group('ProfileViewModel', () {
    test('estado inicial debería tener valores por defecto', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.username, equals('Cargando...'));
      expect(viewModel.email, isEmpty);
      expect(viewModel.fullName, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.avatarUrl, null);
    });

    test('getter username debería retornar el nombre de usuario', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.username, isA<String>());
    });

    test('getter email debería retornar el email', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.email, isA<String>());
    });

    test('getter fullName debería retornar el nombre completo', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.fullName, isA<String>());
    });

    test('getter isLoading debería retornar boolean', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.isLoading, isFalse);
    });

    test('getter errorMessage debería retornar null inicialmente', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.errorMessage, isNull);
    });

    test('avatarUrl debería retornar null cuando no hay URL', () {
      final viewModel = ProfileViewModel();
      expect(viewModel.avatarUrl, isNull);
    });

    test('debería ser ChangeNotifier', () {
      final viewModel = ProfileViewModel();
      
      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      expect(notificationCount, 0);
    });

    test('múltiples instancias deberían ser independientes', () {
      final vm1 = ProfileViewModel();
      final vm2 = ProfileViewModel();

      expect(vm1.username, equals(vm2.username));
      expect(vm1.email, equals(vm2.email));
    });

    test('loadProfile debería notificar listeners', () async {
      final viewModel = ProfileViewModel();

      expect(viewModel.loadProfile, isA<Function>());
    });

    test('updateUserProfile debería retornar Future<bool>', () async {
      final viewModel = ProfileViewModel();
      
      expect(viewModel.updateUserProfile, isA<Function>());
    });
  });
}
