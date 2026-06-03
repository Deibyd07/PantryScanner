import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sqlite_shopping_list_repository.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WEB DEMO — InMemory singleton
// ─────────────────────────────────────────────────────────────────────────────
class _InMemoryShoppingListRepository implements ShoppingListRepository {
  _InMemoryShoppingListRepository._();
  static final _InMemoryShoppingListRepository instance =
      _InMemoryShoppingListRepository._();

  final List<ShoppingListItem> _items = <ShoppingListItem>[];
  final StreamController<List<ShoppingListItem>> _ctrl =
      StreamController<List<ShoppingListItem>>.broadcast();
  int _nextId = 1;

  void _emit() => _ctrl.add(List<ShoppingListItem>.unmodifiable(_items));

  String _norm(String s) => s.toLowerCase().trim();

  @override
  Stream<List<ShoppingListItem>> watchAll() async* {
    yield List<ShoppingListItem>.unmodifiable(_items);
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
    final String n = _norm(name);
    final int existing = _items.indexWhere((ShoppingListItem i) =>
        _norm(i.name) == n &&
        (i.sourceRecipeId ?? '') == (sourceRecipeId ?? '') &&
        !i.isChecked);
    if (existing >= 0) return _items[existing].id;

    final ShoppingListItem item = ShoppingListItem(
      id: _nextId++,
      name: name.trim(),
      quantity: quantity,
      sourceRecipeId: sourceRecipeId,
      sourceTitle: sourceTitle,
      isChecked: false,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    _emit();
    return item.id;
  }

  @override
  Future<int> addItems({required List<ShoppingListItemDraft> drafts}) async {
    int added = 0;
    for (final ShoppingListItemDraft d in drafts) {
      final String n = _norm(d.name);
      final bool dup = _items.any((ShoppingListItem i) =>
          _norm(i.name) == n &&
          (i.sourceRecipeId ?? '') == (d.sourceRecipeId ?? '') &&
          !i.isChecked);
      if (dup) continue;
      _items.insert(
        0,
        ShoppingListItem(
          id: _nextId++,
          name: d.name.trim(),
          quantity: d.quantity,
          sourceRecipeId: d.sourceRecipeId,
          sourceTitle: d.sourceTitle,
          isChecked: false,
          createdAt: DateTime.now(),
        ),
      );
      added++;
    }
    if (added > 0) _emit();
    return added;
  }

  @override
  Future<void> toggleChecked(int id, {required bool isChecked}) async {
    final int idx = _items.indexWhere((ShoppingListItem i) => i.id == id);
    if (idx < 0) return;
    _items[idx] = _items[idx].copyWith(
      isChecked: isChecked,
      checkedAt: isChecked ? DateTime.now() : null,
    );
    _emit();
  }

  @override
  Future<void> deleteItem(int id) async {
    _items.removeWhere((ShoppingListItem i) => i.id == id);
    _emit();
  }

  @override
  Future<void> clearCompleted() async {
    _items.removeWhere((ShoppingListItem i) => i.isChecked);
    _emit();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider — hybrid SQLite on mobile, InMemory on web
// ─────────────────────────────────────────────────────────────────────────────
final FutureProvider<ShoppingListRepository> _sqliteShoppingListRepoProvider =
    FutureProvider<ShoppingListRepository>((Ref ref) async {
  return SqliteShoppingListRepository.init();
});

final Provider<ShoppingListRepository> shoppingListRepositoryProvider =
    Provider<ShoppingListRepository>((Ref ref) {
  if (kIsWeb) return _InMemoryShoppingListRepository.instance;
  return ref.watch(_sqliteShoppingListRepoProvider).when(
        data: (ShoppingListRepository r) => r,
        loading: () => _InMemoryShoppingListRepository.instance,
        error: (_, __) => _InMemoryShoppingListRepository.instance,
      );
});

final StreamProvider<List<ShoppingListItem>> shoppingListProvider =
    StreamProvider<List<ShoppingListItem>>((Ref ref) {
  return ref.watch(shoppingListRepositoryProvider).watchAll();
});

/// Conteo de ítems pendientes (no checked). Útil para mostrar badge.
final Provider<int> shoppingListPendingCountProvider = Provider<int>((Ref ref) {
  final AsyncValue<List<ShoppingListItem>> async =
      ref.watch(shoppingListProvider);
  return async.valueOrNull
          ?.where((ShoppingListItem i) => !i.isChecked)
          .length ??
      0;
});
