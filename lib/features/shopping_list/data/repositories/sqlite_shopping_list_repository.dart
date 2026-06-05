import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';

const Uuid _uuid = Uuid();

class SqliteShoppingListRepository implements ShoppingListRepository {
  SqliteShoppingListRepository._();

  static final SqliteShoppingListRepository _instance =
      SqliteShoppingListRepository._();

  static Future<SqliteShoppingListRepository> init() async {
    _instance._db = await AppDatabase.instance.database;
    return _instance;
  }

  Database? _db;
  String? _currentUserId;
  final StreamController<List<ShoppingListItem>> _ctrl =
      StreamController<List<ShoppingListItem>>.broadcast();

  Database get _database {
    if (_db == null) throw StateError('Database is not initialized.');
    return _db!;
  }

  /// Cambia el usuario activo. Emite la lista actualizada a todos los listeners.
  void setCurrentUser(String? uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    if (_db != null) _emit();
  }

  Future<void> _emit() async {
    if (_db == null) return;
    _ctrl.add(await _queryAll());
  }

  Future<List<ShoppingListItem>> _queryAll() async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty || _db == null) return [];
    final List<Map<String, dynamic>> rows = await _database.query(
      'shopping_list_items',
      where: 'user_id = ?',
      whereArgs: [uid],
      orderBy: 'is_checked ASC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  static ShoppingListItem _fromRow(Map<String, dynamic> row) {
    return ShoppingListItem(
      id: row['id'] as int,
      syncId: (row['sync_id'] as String?) ?? _uuid.v4(),
      name: row['name'] as String,
      quantity: row['quantity'] as String?,
      sourceRecipeId: row['source_recipe'] as String?,
      sourceTitle: row['source_title'] as String?,
      isChecked: (row['is_checked'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      checkedAt: row['checked_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row['checked_at'] as int),
    );
  }

  static String _normalize(String input) {
    const Map<String, String> diacritics = <String, String>{
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n',
    };
    final String lower = input.toLowerCase().trim();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final String ch = lower[i];
      out.write(diacritics[ch] ?? ch);
    }
    return out.toString();
  }

  @override
  Stream<List<ShoppingListItem>> watchAll() async* {
    yield await _queryAll();
    yield* _ctrl.stream;
  }

  @override
  Future<int> addItem({
    required String name,
    String? quantity,
    String? sourceRecipeId,
    String? sourceTitle,
  }) async {
    final String? uid = _currentUserId;
    if (name.trim().isEmpty || uid == null || uid.isEmpty) return 0;

    final String normalized = _normalize(name);
    final List<Map<String, dynamic>> existing = await _database.query(
      'shopping_list_items',
      where: 'user_id = ? AND normalized_name = ? AND IFNULL(source_recipe, "") = IFNULL(?, "") AND is_checked = 0',
      whereArgs: <dynamic>[uid, normalized, sourceRecipeId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int id = await _database.insert('shopping_list_items', <String, dynamic>{
      'sync_id': _uuid.v4(),
      'user_id': uid,
      'name': name.trim(),
      'normalized_name': normalized,
      'quantity': quantity,
      'source_recipe': sourceRecipeId,
      'source_title': sourceTitle,
      'is_checked': 0,
      'created_at': now,
    });
    await _emit();
    return id;
  }

  @override
  Future<int> addItems({required List<ShoppingListItemDraft> drafts}) async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty) return 0;
    int added = 0;
    await _database.transaction((Transaction txn) async {
      for (final ShoppingListItemDraft d in drafts) {
        if (d.name.trim().isEmpty) continue;
        final String normalized = _normalize(d.name);
        final List<Map<String, dynamic>> existing = await txn.query(
          'shopping_list_items',
          where: 'user_id = ? AND normalized_name = ? AND IFNULL(source_recipe, "") = IFNULL(?, "") AND is_checked = 0',
          whereArgs: <dynamic>[uid, normalized, d.sourceRecipeId],
          limit: 1,
        );
        if (existing.isNotEmpty) continue;

        final int now = DateTime.now().millisecondsSinceEpoch;
        await txn.insert('shopping_list_items', <String, dynamic>{
          'sync_id': _uuid.v4(),
          'user_id': uid,
          'name': d.name.trim(),
          'normalized_name': normalized,
          'quantity': d.quantity,
          'source_recipe': d.sourceRecipeId,
          'source_title': d.sourceTitle,
          'is_checked': 0,
          'created_at': now,
        });
        added++;
      }
    });
    if (added > 0) await _emit();
    return added;
  }

  @override
  Future<void> updateItem(
    int id, {
    required String name,
    required String? quantity,
  }) async {
    final String? uid = _currentUserId;
    if (name.trim().isEmpty || uid == null || uid.isEmpty) return;
    await _database.update(
      'shopping_list_items',
      <String, dynamic>{
        'name': name.trim(),
        'normalized_name': _normalize(name),
        'quantity': quantity,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: <dynamic>[id, uid],
    );
    await _emit();
  }

  @override
  Future<void> toggleChecked(int id, {required bool isChecked}) async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _database.update(
      'shopping_list_items',
      <String, dynamic>{
        'is_checked': isChecked ? 1 : 0,
        'checked_at': isChecked ? now : null,
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: <dynamic>[id, uid],
    );
    await _emit();
  }

  @override
  Future<void> markManyChecked(List<int> ids) async {
    final String? uid = _currentUserId;
    if (ids.isEmpty || uid == null || uid.isEmpty) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String placeholders = List<String>.filled(ids.length, '?').join(',');
    await _database.update(
      'shopping_list_items',
      <String, dynamic>{
        'is_checked': 1,
        'checked_at': now,
      },
      where: 'id IN ($placeholders) AND is_checked = 0 AND user_id = ?',
      whereArgs: [...ids, uid],
    );
    await _emit();
  }

  @override
  Future<void> deleteItem(int id) async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty) return;
    await _database.delete(
      'shopping_list_items',
      where: 'id = ? AND user_id = ?',
      whereArgs: <dynamic>[id, uid],
    );
    await _emit();
  }

  @override
  Future<int> restoreItem(ShoppingListItem item) async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty) return 0;
    final int id = await _database.insert('shopping_list_items', <String, dynamic>{
      'sync_id': item.syncId,
      'user_id': uid,
      'name': item.name,
      'normalized_name': _normalize(item.name),
      'quantity': item.quantity,
      'source_recipe': item.sourceRecipeId,
      'source_title': item.sourceTitle,
      'is_checked': item.isChecked ? 1 : 0,
      'created_at': item.createdAt.millisecondsSinceEpoch,
      'checked_at': item.checkedAt?.millisecondsSinceEpoch,
    });
    await _emit();
    return id;
  }

  // ── Cloud sync helpers ───────────────────────────────────────────────────────

  /// Upsert de un ítem proveniente de Firestore (no dispara _emit para que el
  /// caller lo llame una sola vez al final del batch).
  Future<void> saveItemFromCloud(Map<String, dynamic> data, String userId) async {
    final String syncId = data['syncId'] as String;
    final String name = (data['name'] as String?) ?? '';
    if (name.isEmpty) return;

    final List<Map<String, dynamic>> existing = await _database.query(
      'shopping_list_items',
      where: 'sync_id = ? AND user_id = ?',
      whereArgs: <dynamic>[syncId, userId],
      limit: 1,
    );

    final int isChecked = (data['isChecked'] as bool? ?? false) ? 1 : 0;
    final int? checkedAt = data['checkedAt'] as int?;
    final int createdAt =
        data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;

    if (existing.isNotEmpty) {
      await _database.update(
        'shopping_list_items',
        <String, dynamic>{
          'name': name,
          'normalized_name': _normalize(name),
          'quantity': data['quantity'],
          'source_recipe': data['sourceRecipeId'],
          'source_title': data['sourceTitle'],
          'is_checked': isChecked,
          'checked_at': checkedAt,
        },
        where: 'sync_id = ? AND user_id = ?',
        whereArgs: <dynamic>[syncId, userId],
      );
    } else {
      await _database.insert(
        'shopping_list_items',
        <String, dynamic>{
          'sync_id': syncId,
          'user_id': userId,
          'name': name,
          'normalized_name': _normalize(name),
          'quantity': data['quantity'],
          'source_recipe': data['sourceRecipeId'],
          'source_title': data['sourceTitle'],
          'is_checked': isChecked,
          'created_at': createdAt,
          'checked_at': checkedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Elimina localmente el ítem con el [syncId] dado para el [userId] activo.
  Future<void> deleteItemBySyncId(String syncId, String userId) async {
    await _database.delete(
      'shopping_list_items',
      where: 'sync_id = ? AND user_id = ?',
      whereArgs: <dynamic>[syncId, userId],
    );
  }

  /// Emite el estado actual tras aplicar una serie de cambios de cloud.
  Future<void> emitAfterCloudUpdate() async => _emit();

  @override
  Future<void> clearCompleted() async {
    final String? uid = _currentUserId;
    if (uid == null || uid.isEmpty) return;
    await _database.delete(
      'shopping_list_items',
      where: 'is_checked = 1 AND user_id = ?',
      whereArgs: [uid],
    );
    await _emit();
  }
}
