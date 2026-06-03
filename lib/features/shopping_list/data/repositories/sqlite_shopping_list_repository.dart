import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';

class SqliteShoppingListRepository implements ShoppingListRepository {
  SqliteShoppingListRepository._();

  static final SqliteShoppingListRepository _instance =
      SqliteShoppingListRepository._();

  static Future<SqliteShoppingListRepository> init() async {
    _instance._db = await AppDatabase.instance.database;
    return _instance;
  }

  Database? _db;
  final StreamController<List<ShoppingListItem>> _ctrl =
      StreamController<List<ShoppingListItem>>.broadcast();

  Database get _database {
    if (_db == null) throw StateError('Database is not initialized.');
    return _db!;
  }

  Future<void> _emit() async {
    _ctrl.add(await _queryAll());
  }

  Future<List<ShoppingListItem>> _queryAll() async {
    final List<Map<String, dynamic>> rows = await _database.query(
      'shopping_list_items',
      orderBy: 'is_checked ASC, created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  static ShoppingListItem _fromRow(Map<String, dynamic> row) {
    return ShoppingListItem(
      id: row['id'] as int,
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
    if (name.trim().isEmpty) return 0;

    final String normalized = _normalize(name);
    final List<Map<String, dynamic>> existing = await _database.query(
      'shopping_list_items',
      where: 'normalized_name = ? AND IFNULL(source_recipe, "") = IFNULL(?, "") AND is_checked = 0',
      whereArgs: <dynamic>[normalized, sourceRecipeId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      // Ya existe pendiente; no duplica.
      return existing.first['id'] as int;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int id = await _database.insert('shopping_list_items', <String, dynamic>{
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
    int added = 0;
    for (final ShoppingListItemDraft d in drafts) {
      final String normalized = _normalize(d.name);
      final List<Map<String, dynamic>> existing = await _database.query(
        'shopping_list_items',
        where: 'normalized_name = ? AND IFNULL(source_recipe, "") = IFNULL(?, "") AND is_checked = 0',
        whereArgs: <dynamic>[normalized, d.sourceRecipeId],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;

      final int now = DateTime.now().millisecondsSinceEpoch;
      await _database.insert('shopping_list_items', <String, dynamic>{
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
    if (added > 0) await _emit();
    return added;
  }

  @override
  Future<void> toggleChecked(int id, {required bool isChecked}) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _database.update(
      'shopping_list_items',
      <String, dynamic>{
        'is_checked': isChecked ? 1 : 0,
        'checked_at': isChecked ? now : null,
      },
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
    await _emit();
  }

  @override
  Future<void> deleteItem(int id) async {
    await _database.delete(
      'shopping_list_items',
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
    await _emit();
  }

  @override
  Future<void> clearCompleted() async {
    await _database.delete(
      'shopping_list_items',
      where: 'is_checked = 1',
    );
    await _emit();
  }
}
