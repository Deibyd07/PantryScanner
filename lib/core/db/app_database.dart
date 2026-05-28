import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    final Database? existing = _db;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'pantry_scanner.db');

    _db = await openDatabase(
      dbPath,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory_items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    UNIQUE NOT NULL,
        barcode     TEXT    NOT NULL DEFAULT '',
        name        TEXT    NOT NULL,
        brand       TEXT,
        category    TEXT,
        quantity    INTEGER NOT NULL DEFAULT 1,
        expiry_date INTEGER,
        image_url   TEXT,
        notes       TEXT,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE product_cache (
        barcode    TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        brand      TEXT,
        category   TEXT,
        image_url  TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    await _createNotificationSettingsTable(db);
    await _seedNotificationSettings(db);
    await _createSentNotificationsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_cache (
          barcode    TEXT PRIMARY KEY,
          brand      TEXT,
          category   TEXT,
          image_url  TEXT,
          updated_at INTEGER NOT NULL,
          name       TEXT NOT NULL DEFAULT ''
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE inventory_items ADD COLUMN sync_id TEXT DEFAULT ""',
      );
      await db.execute(
        'ALTER TABLE inventory_items ADD COLUMN updated_at INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE inventory_items ADD COLUMN is_deleted INTEGER DEFAULT 0',
      );

      final items = await db.query('inventory_items');
      for (final item in items) {
        final String newSyncId = const Uuid().v4();
        final int now = DateTime.now().millisecondsSinceEpoch;
        await db.update(
          'inventory_items',
          {'sync_id': newSyncId, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }

    if (oldVersion < 4) {
      await _createNotificationSettingsTable(db);
      await _seedNotificationSettings(db);
    }

    if (oldVersion < 5) {
      await _createSentNotificationsTable(db);
    }
  }

  Future<void> _createNotificationSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS configuracion_notificaciones (
        id INTEGER PRIMARY KEY,
        enabled INTEGER NOT NULL DEFAULT 1,
        global_days_before INTEGER NOT NULL DEFAULT 3,
        preferred_hour INTEGER NOT NULL DEFAULT 9,
        preferred_minute INTEGER NOT NULL DEFAULT 0,
        category_overrides TEXT NOT NULL DEFAULT '{}',
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedNotificationSettings(Database db) async {
    final rows = await db.query('configuracion_notificaciones', limit: 1);
    if (rows.isNotEmpty) return;

    await db.insert(
      'configuracion_notificaciones',
      <String, dynamic>{
        'id': 1,
        'enabled': 1,
        'global_days_before': 3,
        'preferred_hour': 9,
        'preferred_minute': 0,
        'category_overrides': '{}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Creates the table that tracks which notifications were already sent per
  /// product per day, preventing duplicate alerts.
  Future<void> _createSentNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sent_notifications (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id   INTEGER NOT NULL,
        sent_date TEXT NOT NULL,
        sent_at   INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sent_notifications_item_date '
      'ON sent_notifications (item_id, sent_date)',
    );
  }

  // ── Deduplication helpers (used by background isolate) ──────────────────────

  /// Returns `true` if a notification was already sent for [itemId] today.
  Future<bool> wasNotificationSentToday(int itemId) async {
    final db = await database;
    final String today = _todayString();
    final rows = await db.query(
      'sent_notifications',
      where: 'item_id = ? AND sent_date = ?',
      whereArgs: [itemId, today],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Records that a notification was sent for [itemId] today.
  Future<void> markNotificationSent(int itemId) async {
    final db = await database;
    final String today = _todayString();
    await db.insert(
      'sent_notifications',
      {
        'item_id': itemId,
        'sent_date': today,
        'sent_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Deletes deduplication records older than 14 days to prevent unbounded
  /// growth of the table.
  Future<void> pruneOldSentNotifications() async {
    final db = await database;
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    final cutoffStr =
        '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';
    await db.delete(
      'sent_notifications',
      where: 'sent_date < ?',
      whereArgs: [cutoffStr],
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
