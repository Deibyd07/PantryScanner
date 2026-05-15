import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app/pantry_scanner_app.dart';
import 'features/notifications/data/services/local_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.setLanguageCode('es');

  // Initialize timezone data for flutter_local_notifications (HU-13)
  tz.initializeTimeZones();

  // Initialize the local notification plugin (HU-13)
  if (!kIsWeb) {
    await LocalNotificationService.instance.init();
  }

  runApp(const ProviderScope(child: PantryScannerApp()));
}
