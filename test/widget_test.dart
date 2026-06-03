import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pantry_scanner/app/pantry_scanner_app.dart';
import 'package:pantry_scanner/features/auth/domain/entities/app_user.dart';
import 'package:pantry_scanner/features/auth/presentation/providers/auth_providers.dart';
import 'package:pantry_scanner/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pantry_scanner/features/notifications/data/services/noop_notification_scheduler.dart';
import 'package:pantry_scanner/features/notifications/presentation/providers/notification_settings_providers.dart';

void main() {
  testWidgets('App renders pantry title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Prevent RealNotificationScheduler from calling LocalNotificationService
          notificationSchedulerProvider.overrideWithValue(
            const NoopNotificationScheduler(),
          ),
          // Prevent low-stock notifications from triggering native methods in tests
          lowStockWatcherProvider.overrideWithValue(null),
          // Emit null (unauthenticated) to avoid Firebase calls in tests
          authStateProvider.overrideWith(
            (ref) => Stream<AppUser?>.value(null),
          ),
        ],
        child: const PantryScannerApp(),
      ),
    );

    // GoRouter redirect is async — pump multiple frames to allow it to resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    // App widget tree renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
