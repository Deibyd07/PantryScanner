import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class PantryScannerApp extends StatefulWidget {
  const PantryScannerApp({super.key});

  @override
  State<PantryScannerApp> createState() => _PantryScannerAppState();
}

class _PantryScannerAppState extends State<PantryScannerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Spanish locale for DateFormat usage
    initializeDateFormatting('es', null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PantryScanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
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
