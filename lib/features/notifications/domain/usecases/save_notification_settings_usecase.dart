import '../entities/notification_settings.dart';
import '../repositories/notification_settings_repository.dart';

class SaveNotificationSettingsUseCase {
  const SaveNotificationSettingsUseCase(this._repository);

  final NotificationSettingsRepository _repository;

  Future<void> call(NotificationSettings settings) {
    return _repository.saveSettings(settings);
  }
}
