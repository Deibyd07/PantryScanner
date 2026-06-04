import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:pantry_scanner/l10n/generated/app_localizations.dart';

/// Smoke test para AuthLogoHeader: widget estático sin dependencias de Firebase.
void main() {
  testWidgets('AuthLogoHeader muestra el nombre de la app', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: AuthLogoHeader()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PantryScanner'), findsOneWidget);
  });
}
