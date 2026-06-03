import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/shared_prefs_settings_repository.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/repositories/settings_repository.dart';

/// Instancia de SharedPreferences inyectada al arrancar la app desde main().
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider debe sobreescribirse en ProviderScope con la '
    'instancia obtenida en main()',
  );
});

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
  return SharedPrefsSettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Estado reactivo del idioma. Cambiar via [LanguageNotifier.set] persiste
/// y reconstruye la app entera (porque MaterialApp.locale lo observa).
class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return ref.read(settingsRepositoryProvider).getLanguage();
  }

  Future<void> set(AppLanguage language) async {
    if (state == language) return;
    state = language;
    await ref.read(settingsRepositoryProvider).setLanguage(language);
  }
}

final NotifierProvider<LanguageNotifier, AppLanguage> languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);
