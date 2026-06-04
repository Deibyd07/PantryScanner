import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/inventory/data/repositories/sqlite_inventory_repository.dart';
import '../../features/inventory/domain/entities/inventory_item.dart';
import '../network/connectivity_provider.dart';
import 'sync_status_provider.dart';

class InventorySyncService {
  InventorySyncService(this.ref, this.localRepo) {
    _init();
  }

  final Ref ref;
  final SqliteInventoryRepository localRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;
  StreamSubscription<List<InventoryItem>>? _localSub;

  String? _currentUid;
  bool _isOnline = false;
  bool _isSyncing = false;
  // Prevents re-push loop when cloud changes update local DB
  bool _isApplyingCloudUpdate = false;
  // Only push items modified after this timestamp
  int _lastPushTimestamp = 0;

  void _init() {
    final AppUser? initialUser = ref.read(authStateProvider).valueOrNull;
    if (initialUser != null) _currentUid = initialUser.uid;

    final bool initialOffline = ref.read(isOfflineProvider).valueOrNull ?? false;
    _isOnline = !initialOffline;

    if (_isOnline && _currentUid != null) _startSync();

    ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, next) {
      final AppUser? user = next.valueOrNull;
      if (user != null) {
        if (_currentUid != user.uid) {
          _currentUid = user.uid;
          _lastPushTimestamp = 0; // force full sync for new user
          _startSync();
        }
      } else {
        _stopSync();
      }
    });

    ref.listen<AsyncValue<bool>>(isOfflineProvider, (_, next) {
      final bool isOffline = next.valueOrNull ?? false;
      _isOnline = !isOffline;
      if (_isOnline && _currentUid != null) _startSync();
    });

    // Push local changes — but skip when the change came from the cloud
    _localSub = localRepo.watchInventory().listen((_) {
      if (_isOnline && _currentUid != null && !_isApplyingCloudUpdate) {
        _pushToCloud();
      }
    });
  }

  void _startSync() {
    if (_currentUid == null || !_isOnline) return;

    _firestoreSub?.cancel();
    _firestoreSub = _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('inventory')
        .snapshots()
        .listen(_onCloudUpdate);

    _pushToCloud();
  }

  void _stopSync() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
    _currentUid = null;
    _lastPushTimestamp = 0;
  }

  Future<void> _pushToCloud() async {
    if (_isSyncing || _currentUid == null || !_isOnline) return;
    _isSyncing = true;
    syncBegin(ref);
    try {
      final String uid = _currentUid!;
      final List<InventoryItem> localItems =
          await localRepo.getSyncableItems(_lastPushTimestamp);

      if (localItems.isEmpty) return;

      // Batch writes: Firestore allows max 500 per batch
      const int chunkSize = 400;
      for (int i = 0; i < localItems.length; i += chunkSize) {
        final List<InventoryItem> chunk =
            localItems.sublist(i, min(i + chunkSize, localItems.length));
        final WriteBatch batch = _firestore.batch();

        for (final InventoryItem item in chunk) {
          final DocumentReference<Map<String, dynamic>> docRef = _firestore
              .collection('users')
              .doc(uid)
              .collection('inventory')
              .doc(item.syncId);

          // Local filesystem paths (start with '/') are device-specific
          // and must not be stored in Firestore.
          final String? cloudImageUrl =
              (item.imageUrl?.startsWith('/') ?? false) ? null : item.imageUrl;

          batch.set(
            docRef,
            <String, dynamic>{
              'syncId': item.syncId,
              'barcode': item.barcode,
              'name': item.name,
              'brand': item.brand,
              'category': item.category,
              'quantity': item.quantity,
              'minStock': item.minStock,
              'expiryDate': item.expiryDate?.millisecondsSinceEpoch,
              'imageUrl': cloudImageUrl,
              'notes': item.notes,
              'createdAt': item.createdAt.millisecondsSinceEpoch,
              'updatedAt': item.updatedAt.millisecondsSinceEpoch,
              'isDeleted': item.isDeleted,
            },
            SetOptions(merge: true),
          );
        }

        await batch.commit();
      }

      _lastPushTimestamp = DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      debugPrint('[InventorySync] Push error: $e');
    } finally {
      syncEnd(ref);
      _isSyncing = false;
    }
  }

  Future<void> _onCloudUpdate(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (snapshot.docChanges.isEmpty) return;

    _isApplyingCloudUpdate = true;
    try {
      for (final DocumentChange<Map<String, dynamic>> change
          in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) continue;

        final Map<String, dynamic>? data = change.doc.data();
        if (data == null) continue;

        try {
          // Discard local filesystem paths that leaked from another device.
          final String? rawImageUrl = data['imageUrl'] as String?;
          final String? safeImageUrl =
              (rawImageUrl?.startsWith('/') ?? false) ? null : rawImageUrl;

          final InventoryItem remoteItem = InventoryItem(
            id: 0,
            syncId: data['syncId'] as String,
            barcode: data['barcode'] as String? ?? '',
            name: data['name'] as String,
            brand: data['brand'] as String?,
            category: data['category'] as String?,
            quantity: data['quantity'] as int? ?? 0,
            minStock: data['minStock'] as int? ?? 1,
            expiryDate: data['expiryDate'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['expiryDate'] as int)
                : null,
            imageUrl: safeImageUrl,
            notes: data['notes'] as String?,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
                data['createdAt'] as int),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
                data['updatedAt'] as int),
            isDeleted: data['isDeleted'] as bool? ?? false,
          );

          await localRepo.saveItemFromCloud(remoteItem);
        } catch (e) {
          debugPrint('[InventorySync] Error parsing cloud item: $e');
        }
      }
    } finally {
      _isApplyingCloudUpdate = false;
    }
  }

  void dispose() {
    _localSub?.cancel();
    _stopSync();
  }
}
