import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementación basada en SharedPreferences (sobrevive a reinicios).
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  static const String _kLanguage = 'settings.language';

  final SharedPreferences _prefs;

  @override
  AppLanguage getLanguage() {
    return AppLanguage.fromCode(_prefs.getString(_kLanguage));
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    await _prefs.setString(_kLanguage, language.code);
  }
}
