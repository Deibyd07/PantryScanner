import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/design/design_system.dart';
import '../features/inventory/presentation/providers/inventory_providers.dart';
import '../features/notifications/presentation/providers/notification_settings_providers.dart';
import '../features/shopping_list/presentation/providers/shopping_list_providers.dart';
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
    initializeDateFormatting('es', null);
    initializeDateFormatting('en', null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios de idioma para sincronizar Firebase Auth
    // fuera de build() — los side effects no van en build.
    ref.listenManual<AppLanguage>(languageProvider, (_, lang) {
      FirebaseAuth.instance.setLanguageCode(lang.code);
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(inventorySyncServiceProvider);
    ref.watch(notificationSettingsSyncProvider);
    ref.watch(shoppingListSyncProvider);

    final AppLanguage language = ref.watch(languageProvider);
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Foodly',
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
