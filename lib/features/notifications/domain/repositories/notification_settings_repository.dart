import '../entities/notification_settings.dart';

abstract class NotificationSettingsRepository {
  Stream<NotificationSettings> watchSettings();

  Future<NotificationSettings> fetchSettings();

  Future<void> saveSettings(NotificationSettings settings);
}
