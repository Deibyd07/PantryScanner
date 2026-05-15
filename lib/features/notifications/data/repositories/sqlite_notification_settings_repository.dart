import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_settings_repository.dart';

class SqliteNotificationSettingsRepository
    implements NotificationSettingsRepository {
  SqliteNotificationSettingsRepository._();

  static final SqliteNotificationSettingsRepository _instance =
      SqliteNotificationSettingsRepository._();

  static Future<SqliteNotificationSettingsRepository> init() async {
    _instance._db = await AppDatabase.instance.database;
    return _instance;
  }

  Database? _db;

  Database get _database {
    final Database? db = _db;
    if (db == null) throw StateError('Database is not initialized.');
    return db;
  }

  final StreamController<NotificationSettings> _ctrl =
      StreamController<NotificationSettings>.broadcast();

  Future<void> _emit() async {
    _ctrl.add(await fetchSettings());
  }

  @override
  Stream<NotificationSettings> watchSettings() async* {
    yield await fetchSettings();
    yield* _ctrl.stream;
  }

  @override
  Future<NotificationSettings> fetchSettings() async {
    final List<Map<String, dynamic>> rows =
        await _database.query('configuracion_notificaciones', limit: 1);
    if (rows.isEmpty) {
      final NotificationSettings defaults = NotificationSettings.defaults();
      await _database.insert(
        'configuracion_notificaciones',
        defaults.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return defaults;
    }
    return NotificationSettings.fromRow(rows.first);
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    final NotificationSettings toSave =
        settings.copyWith(updatedAt: DateTime.now());
    await _database.insert(
      'configuracion_notificaciones',
      toSave.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emit();
  }
}
