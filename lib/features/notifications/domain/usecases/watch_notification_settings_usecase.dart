import '../entities/notification_settings.dart';
import '../repositories/notification_settings_repository.dart';

class WatchNotificationSettingsUseCase {
  const WatchNotificationSettingsUseCase(this._repository);

  final NotificationSettingsRepository _repository;

  Stream<NotificationSettings> call() {
    return _repository.watchSettings();
  }
}
