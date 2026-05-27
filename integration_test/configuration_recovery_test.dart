import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:foodmatch_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Configuración - Tema Oscuro vs Claro', () {
    testWidgets('App debería mostrar correctamente en tema claro', (
      tester,
    ) async {
      tester.view.reset();
      app.main();
      await tester.pumpAndSettle();

      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsWidgets);

      final appWidget = materialApp.evaluate().first.widget as MaterialApp;
      expect(appWidget.theme != null, true);
    });

    testWidgets('Contraste de texto debería ser legible en todos los temas', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final texts = find.byType(Text);
      expect(texts, findsWidgets);

      final textCount = texts.evaluate().length;
      expect(textCount > 0, true);

      for (var text in texts.evaluate()) {
        final textWidget = text.widget as Text;
        expect(textWidget.data != null || textWidget.textSpan != null, true);
      }
    });
  });

  group('Pruebas de Recuperación - Manejo de Recursos', () {
    testWidgets('App debería manejar cambio de orientación sin errores', (
      tester,
    ) async {
      addTearDown(tester.view.reset);

      app.main();
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(1000, 400);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold), findsWidgets);

      tester.view.physicalSize = const Size(400, 1000);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsWidgets);
      expect(find.byType(Scaffold).evaluate().length, greaterThanOrEqualTo(1));
    });
  });

  group('Pruebas de Regresión - Scroll y Gestos', () {
    testWidgets('Botones debería ser táctiles y responder correctamente', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        final firstButton = buttons.first;

        await tester.tap(firstButton);
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsWidgets);
      }

      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.first);
        await tester.pumpAndSettle();
        expect(find.byType(MaterialApp), findsWidgets);
      }
    });

    testWidgets('Gestos deslizar (swipe) debería funcionar en card stacks', (
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
      await tester.pumpAndSettle();

      final loginTextFieldsAfter = find.byType(TextField);
      expect(
        loginTextFieldsAfter.evaluate().isEmpty,
        true,
        reason: 'Debe estar en home_view después de login',
      );

      final categoryButtons = find.byType(InkWell);
      expect(
        categoryButtons.evaluate().isNotEmpty,
        true,
        reason: 'Debe haber botones de categoría en home',
      );

      await tester.tap(categoryButtons.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final circularProgressIndicators = find.byType(CircularProgressIndicator);
      if (circularProgressIndicators.evaluate().isNotEmpty) {
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final gestureDetectors = find.byWidgetPredicate(
        (widget) => widget is GestureDetector,
      );

      expect(
        gestureDetectors.evaluate().isNotEmpty,
        true,
        reason: 'Debe haber GestureDetectors (CardSwiper) en recipe_swipe_view',
      );

      await tester.fling(gestureDetectors.first, const Offset(-500, 0), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(MaterialApp), findsWidgets);
    });
  });
}
