import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pantry_scanner/app/pantry_scanner_app.dart';
import 'package:pantry_scanner/features/auth/domain/entities/app_user.dart';
import 'package:pantry_scanner/features/auth/presentation/providers/auth_providers.dart';
import 'package:pantry_scanner/features/notifications/presentation/providers/notification_settings_providers.dart';
import 'package:pantry_scanner/features/notifications/data/services/noop_notification_scheduler.dart';

void main() {
  testWidgets('App renders pantry title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationSchedulerProvider.overrideWithValue(const NoopNotificationScheduler()),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                uid: '123',
                email: 'test@example.com',
                displayName: 'Test User',
              ),
            ),
          ),
        ],
        child: const PantryScannerApp(),
      ),
    );

    // Let the route transition and sync providers load
    await tester.pumpAndSettle();
    expect(find.text('Mi despensa'), findsOneWidget);
  });
}


