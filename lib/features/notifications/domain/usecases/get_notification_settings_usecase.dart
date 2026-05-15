import '../entities/notification_settings.dart';
import '../repositories/notification_settings_repository.dart';

class GetNotificationSettingsUseCase {
  const GetNotificationSettingsUseCase(this._repository);

  final NotificationSettingsRepository _repository;

  Future<NotificationSettings> call() {
    return _repository.fetchSettings();
  }
}
