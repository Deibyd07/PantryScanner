import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pantry_scanner/app/pantry_scanner_app.dart';

void main() {
  testWidgets('App renders pantry title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PantryScannerApp(),
      ),
    );

    await tester.pump();
    expect(find.text('My Pantry'), findsOneWidget);
  });
}
