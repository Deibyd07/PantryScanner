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
      version: 1,
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

  static Map<String, dynamic> _toRow(InventoryItem item) {
    return <String, dynamic>{
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
  }

  // ── InventoryRepository ───────────────────────────────────────────────────

  @override
  Stream<List<InventoryItem>> watchInventory() async* {
    yield await _queryAll();
    yield* _ctrl.stream;
  }

  @override
  Future<int> saveItem(InventoryItem item) async {
    final id = await _database.insert(
      'inventory_items',
      _toRow(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
