import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app/pantry_scanner_app.dart';
import 'features/notifications/data/services/local_notification_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Crashlytics ─────────────────────────────────────────────────────────────
  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // ── Error widget amigable (release mode) ─────────────────────────────────
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFB71C1C)),
              SizedBox(height: 16),
              Text(
                'Algo salió mal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Intenta reiniciar la aplicación.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize timezone data for flutter_local_notifications (HU-13)
  tz.initializeTimeZones();

  // Initialize the local notification plugin (HU-13)
  if (!kIsWeb) {
    await LocalNotificationService.instance.init();
    await LocalNotificationService.instance.requestPermission();
  }

  // Bootstrap SharedPreferences antes de runApp para que el provider
  // del idioma pueda leer el valor persistido en su primer build.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String savedLang = prefs.getString('settings.language') ?? 'es';
  FirebaseAuth.instance.setLanguageCode(savedLang);

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const PantryScannerApp(),
    ),
  );
}
