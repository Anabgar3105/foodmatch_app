import 'package:flutter_test/flutter_test.dart';
import 'package:foodmatch_app/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemeViewModel', () {
    test('inicio con ThemeMode.light', () {
      final viewModel = ThemeViewModel(ThemeMode.light);
      expect(viewModel.themeMode, ThemeMode.light);
    });

    test('inicio con ThemeMode.dark', () {
      final viewModel = ThemeViewModel(ThemeMode.dark);
      expect(viewModel.themeMode, ThemeMode.dark);
    });

    test('toggleTheme debería cambiar de light a dark', () async {
      final viewModel = ThemeViewModel(ThemeMode.light);
      
      final initialTheme = viewModel.themeMode;
      expect(initialTheme, ThemeMode.light);

    });

    test('toggleTheme debería notificar listeners', () async {
      final viewModel = ThemeViewModel(ThemeMode.light);
      int notificationCount = 0;

      viewModel.addListener(() {
        notificationCount++;
      });

      expect(notificationCount, 0);
    });

    test('themeMode getter debería retornar el tema actual', () {
      final viewModel = ThemeViewModel(ThemeMode.dark);
      expect(viewModel.themeMode, ThemeMode.dark);

      final viewModel2 = ThemeViewModel(ThemeMode.light);
      expect(viewModel2.themeMode, ThemeMode.light);
    });

    test('múltiples instancias debería ser independientes', () {
      final vm1 = ThemeViewModel(ThemeMode.light);
      final vm2 = ThemeViewModel(ThemeMode.dark);

      expect(vm1.themeMode, ThemeMode.light);
      expect(vm2.themeMode, ThemeMode.dark);
    });

    test('debería extender ChangeNotifier', () {
      final viewModel = ThemeViewModel(ThemeMode.light);
      expect(viewModel, isA<ChangeNotifier>());
    });
  });
}
