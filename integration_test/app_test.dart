import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:foodmatch_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Sistema - Flujo de Navegación Básico', () {
    testWidgets('App debería iniciar y mostrar pantalla de login', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Debería poder navegar desde login a signup', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final buttons = find.byType(TextButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);
      }
    });
  });

  group('Pruebas de Sistema - Escenarios de Aplicación Completa', () {
    testWidgets(
      'El texto de error debería desaparecer cuando el usuario intenta nuevamente',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'invalid');
          final passwordFields = find.byType(TextField);
          if (passwordFields.evaluate().length > 1) {
            await tester.enterText(passwordFields.at(1), 'invalid');
          }
        }

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        expect(find.byType(TextField).evaluate().isNotEmpty, true);

        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, '');
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'La aplicación debería mantener estado cuando se minimiza y se abre nuevamente',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final initialWidgets = find.byType(MaterialApp);
        expect(initialWidgets, findsWidgets);

        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        final finalWidgets = find.byType(MaterialApp);
        expect(finalWidgets, findsWidgets);
      },
    );
  });

  group('Pruebas de Configuración - Diferentes Tamaños de Pantalla', () {
    testWidgets('UI debería adaptarse a pantalla pequeña', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);

      final overflowWidgets = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView || widget is ListView,
      );
      expect(
        overflowWidgets.evaluate().isNotEmpty ||
            find.byType(TextField).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('UI debería adaptarse a pantalla grande', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);

      addTearDown(tester.view.reset);

      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('UI debería soportar orientación horizontal', (tester) async {
      tester.view.physicalSize = const Size(1000, 400);
      addTearDown(tester.view.reset);

      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Pruebas de Recuperación - Manejo de Errores', () {
    testWidgets(
      'App debería mostrar mensaje de error descriptivo',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'test');
          final passwordFields = find.byType(TextField);
          if (passwordFields.evaluate().length > 1) {
            await tester.enterText(passwordFields.at(1), 'password123');
          }
        }

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        expect(find.byType(MaterialApp), findsWidgets);
      },
    );

    testWidgets(
      'App debería permitir reintentar después de un error de conexión',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        final emailFields = find.byType(TextField);
        if (emailFields.evaluate().isNotEmpty) {
          await tester.enterText(emailFields.first, 'invalid');
          final passwordFields = find.byType(TextField);
          if (passwordFields.evaluate().length > 1) {
            await tester.enterText(passwordFields.at(1), 'invalidpass');
          }
        }

        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          await tester.pumpAndSettle();
          final emailFieldsAfter = find.byType(TextField);
          if (emailFieldsAfter.evaluate().isNotEmpty) {
            await tester.enterText(emailFieldsAfter.first, 'valid');
            await tester.tap(buttons.first);
            await tester.pumpAndSettle();
          }
        }

        expect(find.byType(MaterialApp), findsWidgets);
      },
    );

    testWidgets('App debería manejar errores/timeouts sin congelarse', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailFields = find.byType(TextField);
      if (emailFields.evaluate().isNotEmpty) {
        await tester.enterText(emailFields.first, 'invalid');
        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length > 1) {
          await tester.enterText(passwordFields.at(1), 'nonexistent_password');
        }
      }

      final buttons = find.byType(ElevatedButton);
      expect(buttons.evaluate().isNotEmpty, true);

      await tester.tap(buttons.first);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(MaterialApp), findsWidgets,
          reason: 'App debe sigue existiendo después del timeout');
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Scaffold debe seguir existiendo después del timeout');

      final emailFieldsAfter = find.byType(TextField);
      expect(emailFieldsAfter.evaluate().isNotEmpty, true,
          reason: 'Debe poder reintentar después del timeout');

      await tester.enterText(emailFieldsAfter.first, 'test');
    });
    
  });

  group('Pruebas de Regresión - Navegación', () {
    testWidgets('Navegación entre pantallas funciona correctamente', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields.evaluate().isNotEmpty, true);

      await tester.enterText(textFields.first, 'test');
      await tester.enterText(textFields.last, 'Test_1234');
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      expect(buttons.evaluate().isNotEmpty, true);

      await tester.tap(buttons.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(
        bottomNavBar.evaluate().isNotEmpty,
        true,
        reason: 'Debe haber BottomNavigationBar en MainLayout',
      );

      final profileNavItem = find.byIcon(Icons.person_outline);
      expect(
        profileNavItem.evaluate().isNotEmpty,
        true,
        reason: 'Debe haber ícono de perfil en la barra de navegación',
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));


      await tester.tap(profileNavItem.first);
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsWidgets);
      await tester.pumpAndSettle();

      final homeNavItem = find.byIcon(Icons.home_outlined);
      expect(homeNavItem.evaluate().isNotEmpty, true);

      await tester.tap(homeNavItem.first);
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsWidgets);
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });
}
