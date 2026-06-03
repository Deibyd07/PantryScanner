import '../entities/app_language.dart';

/// Persistencia de preferencias del usuario (clave-valor).
abstract class SettingsRepository {
  AppLanguage getLanguage();
  Future<void> setLanguage(AppLanguage language);
}
