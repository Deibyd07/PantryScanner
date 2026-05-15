import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
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
    _instance._db = await AppDatabase.instance.database;
    return _instance;
  }

  Database? _db;
  final Uuid _uuid = const Uuid();

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
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  // Raw query for Sync Service (includes deleted items)
  Future<List<InventoryItem>> getSyncableItems(int lastSyncTimestamp) async {
    final rows = await _database.query(
      'inventory_items',
      where: 'updated_at > ?',
      whereArgs: [lastSyncTimestamp],
    );
    return rows.map(_fromRow).toList();
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

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
      syncId: row['sync_id'] as String? ?? '',
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
      updatedAt: row['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int)
          : DateTime.now(),
      isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
    );
  }

  static Map<String, dynamic> _toRow(InventoryItem item) {
    final Map<String, dynamic> row = <String, dynamic>{
      'sync_id': item.syncId,
      'barcode': item.barcode,
      'name': item.name,
      'brand': item.brand,
      'category': item.category,
      'quantity': item.quantity,
      'expiry_date': item.expiryDate?.millisecondsSinceEpoch,
      'image_url': item.imageUrl,
      'notes': item.notes,
      'created_at': item.createdAt.millisecondsSinceEpoch,
      'updated_at': item.updatedAt.millisecondsSinceEpoch,
      'is_deleted': item.isDeleted ? 1 : 0,
    };
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
      where: 'barcode = ? AND is_deleted = 0',
      whereArgs: <dynamic>[barcode],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<int> saveItem(InventoryItem item) async {
    // Generate syncId and set timestamps if missing/new
    final String syncId = item.syncId.isEmpty ? _uuid.v4() : item.syncId;
    final DateTime now = DateTime.now();
    
    final InventoryItem itemToSave = InventoryItem(
      id: item.id,
      syncId: syncId,
      barcode: item.barcode,
      name: item.name,
      brand: item.brand,
      category: item.category,
      quantity: item.quantity,
      createdAt: item.id == 0 ? now : item.createdAt,
      updatedAt: now,
      isDeleted: false,
      expiryDate: item.expiryDate,
      imageUrl: item.imageUrl,
      notes: item.notes,
    );

    final int id = await _database.insert(
      'inventory_items',
      _toRow(itemToSave),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _cacheProduct(itemToSave);
    await _emit();
    return id;
  }

  // Exclusive for sync service
  Future<void> saveItemFromCloud(InventoryItem item) async {
    // Try to find if item exists locally to keep the same integer ID
    final existingRows = await _database.query(
      'inventory_items',
      where: 'sync_id = ?',
      whereArgs: [item.syncId],
      limit: 1,
    );

    InventoryItem finalItem = item;
    if (existingRows.isNotEmpty) {
      final int existingId = existingRows.first['id'] as int;
      finalItem = InventoryItem(
        id: existingId,
        syncId: item.syncId,
        barcode: item.barcode,
        name: item.name,
        brand: item.brand,
        category: item.category,
        quantity: item.quantity,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        isDeleted: item.isDeleted,
        expiryDate: item.expiryDate,
        imageUrl: item.imageUrl,
        notes: item.notes,
      );
    }

    await _database.insert(
      'inventory_items',
      _toRow(finalItem),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emit();
  }

  @override
  Future<void> deleteItem(int id) async {
    // Soft delete locally
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _database.update(
      'inventory_items',
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
    await _emit();
  }
}
