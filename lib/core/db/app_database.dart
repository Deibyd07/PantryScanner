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
      version: 6,
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
        min_stock   INTEGER NOT NULL DEFAULT 1,
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
    await _createShoppingListTable(db);
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
      await db.execute(
        'ALTER TABLE inventory_items ADD COLUMN min_stock INTEGER NOT NULL DEFAULT 1',
      );
    }

    if (oldVersion < 6) {
      await _createShoppingListTable(db);
    }
  }

  Future<void> _createShoppingListTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shopping_list_items (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        name            TEXT    NOT NULL,
        normalized_name TEXT    NOT NULL,
        quantity        TEXT,
        source_recipe   TEXT,
        source_title    TEXT,
        is_checked      INTEGER NOT NULL DEFAULT 0,
        created_at      INTEGER NOT NULL,
        checked_at      INTEGER
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_shopping_list_dedupe
        ON shopping_list_items (normalized_name, source_recipe)
    ''');
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
}
