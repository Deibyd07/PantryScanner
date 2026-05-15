import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sqlite_notification_settings_repository.dart';
import '../../data/services/noop_notification_scheduler.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../domain/usecases/get_notification_settings_usecase.dart';
import '../../domain/usecases/save_notification_settings_usecase.dart';
import '../../domain/usecases/watch_notification_settings_usecase.dart';

final Provider<NotificationScheduler> notificationSchedulerProvider =
    Provider<NotificationScheduler>((ref) {
  return const NoopNotificationScheduler();
});

final _InMemoryNotificationSettingsRepository _globalWebRepo =
    _InMemoryNotificationSettingsRepository._();

class _InMemoryNotificationSettingsRepository
    implements NotificationSettingsRepository {
  _InMemoryNotificationSettingsRepository._();

  NotificationSettings _settings = NotificationSettings.defaults();

  final StreamController<NotificationSettings> _ctrl =
      StreamController<NotificationSettings>.broadcast();

  void _emit() => _ctrl.add(_settings);

  @override
  Stream<NotificationSettings> watchSettings() async* {
    yield _settings;
    yield* _ctrl.stream;
  }

  @override
  Future<NotificationSettings> fetchSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    _settings = settings.copyWith(updatedAt: DateTime.now());
    _emit();
  }
}

final _sqliteNotificationSettingsRepoProvider =
    FutureProvider<NotificationSettingsRepository>((ref) async {
  return SqliteNotificationSettingsRepository.init();
});

final Provider<NotificationSettingsRepository>
    notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  if (kIsWeb) {
    return _globalWebRepo;
  }
  return ref.watch(_sqliteNotificationSettingsRepoProvider).when(
        data: (repo) => repo,
        loading: () => _globalWebRepo,
        error: (_, __) => _globalWebRepo,
      );
});

final Provider<GetNotificationSettingsUseCase>
    getNotificationSettingsUseCaseProvider =
    Provider<GetNotificationSettingsUseCase>((ref) {
  return GetNotificationSettingsUseCase(
    ref.watch(notificationSettingsRepositoryProvider),
  );
});

final Provider<SaveNotificationSettingsUseCase>
    saveNotificationSettingsUseCaseProvider =
    Provider<SaveNotificationSettingsUseCase>((ref) {
  return SaveNotificationSettingsUseCase(
    ref.watch(notificationSettingsRepositoryProvider),
  );
});

final Provider<WatchNotificationSettingsUseCase>
    watchNotificationSettingsUseCaseProvider =
    Provider<WatchNotificationSettingsUseCase>((ref) {
  return WatchNotificationSettingsUseCase(
    ref.watch(notificationSettingsRepositoryProvider),
  );
});

final StreamProvider<NotificationSettings> notificationSettingsProvider =
    StreamProvider<NotificationSettings>((ref) {
  return ref.watch(watchNotificationSettingsUseCaseProvider).call();
});

final Provider<void> notificationSettingsSyncProvider = Provider<void>((ref) {
  final NotificationScheduler scheduler =
      ref.watch(notificationSchedulerProvider);
  final NotificationSettingsRepository repo =
      ref.watch(notificationSettingsRepositoryProvider);

  final sub = repo.watchSettings().listen((settings) {
    scheduler.applySettings(settings);
  });

  ref.onDispose(sub.cancel);
  return null;
});
