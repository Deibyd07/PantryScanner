import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/design/design_system.dart';
import '../features/inventory/presentation/providers/inventory_providers.dart';
import '../features/notifications/data/services/local_notification_service.dart';
import '../features/notifications/presentation/providers/notification_settings_providers.dart';
import 'router/app_router.dart';

/// Riverpod provider that holds the auth-aware GoRouter instance.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});

class PantryScannerApp extends ConsumerStatefulWidget {
  const PantryScannerApp({super.key});

  @override
  ConsumerState<PantryScannerApp> createState() => _PantryScannerAppState();
}

class _PantryScannerAppState extends ConsumerState<PantryScannerApp> {
  StreamSubscription<String?>? _notificationSub;

  @override
  void initState() {
    super.initState();
    // Initialize Spanish locale for DateFormat usage
    initializeDateFormatting('es', null);

    // Listen for notification taps (payload = 'product_form:<barcode>')
    if (!kIsWeb) {
      _notificationSub = LocalNotificationService.instance.payloadStream
          .listen(_handleNotificationPayload);
    }
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    // Expected format: 'product_form:<barcode>'
    if (payload.startsWith('product_form:')) {
      final barcode = payload.substring('product_form:'.length);
      // Navigate after the frame so the router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(routerProvider).go(
          '${AppRoutes.productForm}?barcode=${Uri.encodeComponent(barcode)}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the sync service
    ref.watch(inventorySyncServiceProvider);
    ref.watch(notificationSettingsSyncProvider);
    
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PantryScanner',
      debugShowCheckedModeBanner: false,
      theme: AppThemeLight.theme,
      darkTheme: AppThemeDark.theme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('es'),
        Locale('en'),
      ],
    );
  }
}
