import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../data/repositories/sqlite_inventory_repository.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../domain/usecases/save_inventory_item_usecase.dart';
import '../../domain/usecases/update_inventory_item_quantity_usecase.dart';
import '../../domain/usecases/watch_inventory_items_usecase.dart';
import '../../../../core/sync/inventory_sync_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WEB DEMO — InMemory singleton repository
// Used only when kIsWeb == true (SQLite is not available on browsers)
// ─────────────────────────────────────────────────────────────────────────────
final _InMemoryInventoryRepository _globalWebRepo =
    _InMemoryInventoryRepository._();

class _InMemoryInventoryRepository implements InventoryRepository {
  _InMemoryInventoryRepository._() {
    // Seed with demo data
    _items.addAll(<InventoryItem>[
      InventoryItem(
        id: 1,
        syncId: '',
        barcode: '12345',
        name: 'Aguacates Hass',
        brand: 'Generico',
        category: 'Frutas y verduras',
        quantity: 2,
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        imageUrl:
            'https://images.unsplash.com/photo-1601039641847-7857b994d704?q=80&w=800',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: 2,
        syncId: '',
        barcode: '67890',
        name: 'Yogur griego',
        brand: 'Alpina',
        category: 'Lácteos',
        quantity: 1,
        expiryDate: DateTime.now().add(const Duration(days: 12)),
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?q=80&w=800',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: 3,
        syncId: '',
        barcode: '11111',
        name: 'Arroz integral',
        brand: null,
        category: 'Cereales',
        quantity: 3,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        imageUrl:
            'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=800',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InventoryItem(
        id: 4,
        syncId: '',
        barcode: '22222',
        name: 'Leche entera',
        brand: 'Parmalat',
        category: 'Lácteos',
        quantity: 0,
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl:
            'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=800',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  final List<InventoryItem> _items = <InventoryItem>[];
  final StreamController<List<InventoryItem>> _ctrl =
      StreamController<List<InventoryItem>>.broadcast();

  void _emit() => _ctrl.add(List<InventoryItem>.unmodifiable(_items));

  @override
  Stream<List<InventoryItem>> watchInventory() async* {
    yield List<InventoryItem>.unmodifiable(_items);
    yield* _ctrl.stream;
  }

  @override
  Future<InventoryItem?> getItemByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;
    try {
      return _items.firstWhere((i) => i.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> saveItem(InventoryItem item) async {
    // If item.id != 0, try to find existing item to update.
    final int existingIndex = item.id != 0
        ? _items.indexWhere((i) => i.id == item.id)
        : -1;

    final int newId = existingIndex >= 0
        ? item.id
        : (_items.isEmpty ? 1 : _items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final InventoryItem newItem = InventoryItem(
      id: newId,
      syncId: item.syncId,
      barcode: item.barcode,
      name: item.name,
      brand: item.brand,
      category: item.category,
      quantity: item.quantity,
      expiryDate: item.expiryDate,
      imageUrl: item.imageUrl,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = newItem;
    } else {
      _items.add(newItem);
    }

    _emit();
    return newId;
  }

  @override
  Future<void> deleteItem(int id) async {
    _items.removeWhere((InventoryItem i) => i.id == id);
    _emit();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider — hybrid: SQLite on mobile, InMemory on web
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the async-initialized SQLite repository for mobile.
/// On web, this will never be read (we use _globalWebRepo instead).
final _sqliteRepoProvider =
    FutureProvider<InventoryRepository>((ref) async {
  return SqliteInventoryRepository.init();
});

final Provider<InventoryRepository> inventoryRepositoryProvider =
    Provider<InventoryRepository>((ref) {
  if (kIsWeb) {
    return _globalWebRepo;
  }
  // On mobile, unwrap the async SQLite repo. While it's loading,
  // fall back to the in-memory repo so the UI never crashes.
  return ref.watch(_sqliteRepoProvider).when(
        data: (repo) => repo,
        loading: () => _globalWebRepo,
        error: (_, __) => _globalWebRepo,
      );
});

// ─────────────────────────────────────────────────────────────────────────────
// Use-case providers
// ─────────────────────────────────────────────────────────────────────────────
final Provider<WatchInventoryItemsUseCase> watchInventoryItemsUseCaseProvider =
    Provider<WatchInventoryItemsUseCase>((ref) {
  return WatchInventoryItemsUseCase(ref.watch(inventoryRepositoryProvider));
});

final Provider<SaveInventoryItemUseCase> saveInventoryItemUseCaseProvider =
    Provider<SaveInventoryItemUseCase>((ref) {
  return SaveInventoryItemUseCase(ref.watch(inventoryRepositoryProvider));
});

final Provider<DeleteInventoryItemUseCase> deleteInventoryItemUseCaseProvider =
    Provider<DeleteInventoryItemUseCase>((ref) {
  return DeleteInventoryItemUseCase(ref.watch(inventoryRepositoryProvider));
});

final Provider<UpdateInventoryItemQuantityUseCase>
    updateInventoryItemQuantityUseCaseProvider =
    Provider<UpdateInventoryItemQuantityUseCase>((ref) {
  return UpdateInventoryItemQuantityUseCase(
      ref.watch(inventoryRepositoryProvider));
});

final StreamProvider<List<InventoryItem>> inventoryItemsProvider =
    StreamProvider<List<InventoryItem>>((ref) {
  return ref.watch(watchInventoryItemsUseCaseProvider).call();
});

/// Returns the full existing InventoryItem if found by barcode.
final AutoDisposeFutureProviderFamily<InventoryItem?, String>
    itemByBarcodeProvider = FutureProvider.autoDispose
        .family<InventoryItem?, String>((ref, barcode) async {
  if (barcode.isEmpty) return null;
  return ref.read(inventoryRepositoryProvider).getItemByBarcode(barcode);
});

/// Returns cached product metadata for [barcode], or null if not cached.
final AutoDisposeFutureProviderFamily<Map<String, dynamic>?, String>
    productCacheProvider = FutureProvider.autoDispose
        .family<Map<String, dynamic>?, String>((ref, barcode) async {
  if (barcode.isEmpty) return null;
  if (kIsWeb) return null; // No SQLite cache on web

  final InventoryRepository repo = ref.read(inventoryRepositoryProvider);
  if (repo is SqliteInventoryRepository) {
    return repo.lookupCache(barcode);
  }
  return null;
});

// ─────────────────────────────────────────────────────────────────────────────
// Sync Service Provider
// ─────────────────────────────────────────────────────────────────────────────
final inventorySyncServiceProvider = Provider<InventorySyncService?>((ref) {
  if (kIsWeb) return null;
  final repo = ref.watch(inventoryRepositoryProvider);
  if (repo is SqliteInventoryRepository) {
    return InventorySyncService(ref, repo);
  }
  return null;
});
