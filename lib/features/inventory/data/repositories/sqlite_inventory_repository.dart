import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SQLite implementation of InventoryRepository — Mobile only (Android / iOS)
// ─────────────────────────────────────────────────────────────────────────────
class SqliteInventoryRepository implements InventoryRepository {
  SqliteInventoryRepository._();

  static final SqliteInventoryRepository _instance =
      SqliteInventoryRepository._();

  /// Call [init] once before using this repository.
  static Future<SqliteInventoryRepository> init() async {
    await _instance._openDb();
    return _instance;
  }

  Database? _db;

  // ── DB lifecycle ──────────────────────────────────────────────────────────

  Future<void> _openDb() async {
    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'pantry_scanner.db');

    _db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inventory_items (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode     TEXT    NOT NULL DEFAULT '',
            name        TEXT    NOT NULL,
            brand       TEXT,
            category    TEXT,
            quantity    INTEGER NOT NULL DEFAULT 1,
            expiry_date INTEGER,
            image_url   TEXT,
            notes       TEXT,
            created_at  INTEGER NOT NULL
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration v1 → v2: add product cache table
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
      },
    );
  }

  Database get _database {
    if (_db == null) throw StateError('Database is not initialized.');
    return _db!;
  }

  // ── Reactive stream ───────────────────────────────────────────────────────

  final StreamController<List<InventoryItem>> _ctrl =
      StreamController<List<InventoryItem>>.broadcast();

  Future<void> _emit() async {
    final items = await _queryAll();
    _ctrl.add(items);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<InventoryItem>> _queryAll() async {
    final rows = await _database.query(
      'inventory_items',
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  /// Looks up a barcode in the local product_cache table.
  /// Returns null if the barcode hasn't been cached yet.
  Future<Map<String, dynamic>?> lookupCache(String barcode) async {
    if (barcode.isEmpty) return null;
    final List<Map<String, dynamic>> rows = await _database.query(
      'product_cache',
      where: 'barcode = ?',
      whereArgs: <dynamic>[barcode],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }


  /// Upserts a product into the cache so it can be auto-filled offline.
  Future<void> _cacheProduct(InventoryItem item) async {
    if (item.barcode.isEmpty) return;
    await _database.insert(
      'product_cache',
      <String, dynamic>{
        'barcode': item.barcode,
        'name': item.name,
        'brand': item.brand,
        'category': item.category,
        'image_url': item.imageUrl,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static InventoryItem _fromRow(Map<String, dynamic> row) {
    return InventoryItem(
      id: row['id'] as int,
      barcode: row['barcode'] as String? ?? '',
      name: row['name'] as String,
      brand: row['brand'] as String?,
      category: row['category'] as String?,
      quantity: row['quantity'] as int,
      expiryDate: row['expiry_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['expiry_date'] as int)
          : null,
      imageUrl: row['image_url'] as String?,
      notes: row['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }

  /// Builds a row map for SQLite.
  /// If [item.id] > 0 (i.e. it is a restore after undo), the id is included
  /// so that ConflictAlgorithm.replace reinstates the original row with the
  /// same primary key, keeping references consistent.
  static Map<String, dynamic> _toRow(InventoryItem item) {
    final Map<String, dynamic> row = <String, dynamic>{
      'barcode': item.barcode,
      'name': item.name,
      'brand': item.brand,
      'category': item.category,
      'quantity': item.quantity,
      'expiry_date': item.expiryDate?.millisecondsSinceEpoch,
      'image_url': item.imageUrl,
      'notes': item.notes,
      'created_at': item.createdAt.millisecondsSinceEpoch,
    };
    // Only include the id when restoring an existing item (id != 0).
    if (item.id != 0) row['id'] = item.id;
    return row;
  }

  // ── InventoryRepository ───────────────────────────────────────────────────

  @override
  Stream<List<InventoryItem>> watchInventory() async* {
    yield await _queryAll();
    yield* _ctrl.stream;
  }

  @override
  Future<InventoryItem?> getItemByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;
    final List<Map<String, dynamic>> rows = await _database.query(
      'inventory_items',
      where: 'barcode = ?',
      whereArgs: <dynamic>[barcode],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<int> saveItem(InventoryItem item) async {
    final int id = await _database.insert(
      'inventory_items',
      _toRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Cache product metadata for offline auto-fill
    await _cacheProduct(item);
    await _emit();
    return id;
  }

  @override
  Future<void> deleteItem(int id) async {
    await _database.delete(
      'inventory_items',
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
    await _emit();
  }
}
