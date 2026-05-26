import '../../domain/entities/notification_settings.dart';
import '../../domain/services/notification_scheduler.dart';

class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<void> applySettings(NotificationSettings settings) async {}
}
