import '../entities/notification_settings.dart';

abstract class NotificationScheduler {
  Future<void> applySettings(NotificationSettings settings);
}
