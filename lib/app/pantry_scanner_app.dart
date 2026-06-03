import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/design/design_system.dart';
import '../features/inventory/presentation/providers/inventory_providers.dart';
import '../features/notifications/presentation/providers/notification_settings_providers.dart';
import '../features/settings/domain/entities/app_language.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import '../l10n/generated/app_localizations.dart';
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
  @override
  void initState() {
    super.initState();
    // Initialize both locales for DateFormat usage.
    initializeDateFormatting('es', null);
    initializeDateFormatting('en', null);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(inventorySyncServiceProvider);
    ref.watch(notificationSettingsSyncProvider);

    final AppLanguage language = ref.watch(languageProvider);
    // Mantener Firebase Auth sincronizado con el idioma elegido.
    FirebaseAuth.instance.setLanguageCode(language.code);

    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PantryScanner',
      debugShowCheckedModeBanner: false,
      // Bloqueado en tema claro por requisito de producto (solo blanco).
      theme: AppThemeLight.theme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: language.locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
