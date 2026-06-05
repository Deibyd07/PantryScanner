import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/shopping_list/data/repositories/sqlite_shopping_list_repository.dart';
import '../../features/shopping_list/domain/entities/shopping_list_item.dart';
import '../db/app_database.dart';
import '../network/connectivity_provider.dart';
import 'sync_status_provider.dart';

class ShoppingListSyncService {
  ShoppingListSyncService(this.ref, this.localRepo) {
    _init();
  }

  final Ref ref;
  final SqliteShoppingListRepository localRepo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;
  StreamSubscription<List<ShoppingListItem>>? _localSub;

  String? _currentUid;
  bool _isOnline = false;
  bool _isSyncing = false;
  bool _isApplyingCloudUpdate = false;

  // Previous local syncIds to detect deletions
  Set<String> _lastKnownSyncIds = <String>{};

  void _init() async {
    final bool initialOffline = ref.read(isOfflineProvider).valueOrNull ?? false;
    _isOnline = !initialOffline;

    ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, AsyncValue<AppUser?> next) async {
      final AppUser? user = next.valueOrNull;
      if (user != null) {
        if (_currentUid != user.uid) {
          _stopSync();               // _currentUid = null, localRepo sin usuario
          _lastKnownSyncIds = <String>{};
          _currentUid = user.uid;
          localRepo.setCurrentUser(user.uid);
          _startSync();
        }
      } else {
        final String? prevUid = _currentUid;
        _stopSync();               // _currentUid = null, localRepo sin usuario
        if (prevUid != null) {
          await AppDatabase.instance.clearUserData(prevUid);
        }
      }
    });

    ref.listen<AsyncValue<bool>>(isOfflineProvider, (_, AsyncValue<bool> next) {
      final bool isOffline = next.valueOrNull ?? false;
      _isOnline = !isOffline;
      if (_isOnline && _currentUid != null) _startSync();
    });

    final AppUser? initialUser = ref.read(authStateProvider).valueOrNull;
    if (initialUser != null) {
      _currentUid = initialUser.uid;
      localRepo.setCurrentUser(initialUser.uid);
      if (_isOnline) _startSync();
    }

    _localSub = localRepo.watchAll().listen((List<ShoppingListItem> items) {
      if (_isOnline && _currentUid != null && !_isApplyingCloudUpdate) {
        _pushToCloud(items);
      }
    });
  }

  void _startSync() {
    if (_currentUid == null || !_isOnline) return;

    _firestoreSub?.cancel();
    _firestoreSub = _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('shopping_list')
        .snapshots()
        .listen(_onCloudUpdate);

    localRepo.watchAll().first.then(_pushToCloud);
  }

  void _stopSync() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
    _currentUid = null;
    _lastKnownSyncIds = <String>{};
    localRepo.setCurrentUser(null);
  }

  Future<void> _pushToCloud(List<ShoppingListItem> items) async {
    if (_isSyncing || _currentUid == null || !_isOnline) return;
    _isSyncing = true;
    syncBegin(ref);
    try {
      final String uid = _currentUid!;
      final CollectionReference<Map<String, dynamic>> col = _firestore
          .collection('users')
          .doc(uid)
          .collection('shopping_list');

      final Set<String> currentSyncIds =
          items.map((ShoppingListItem i) => i.syncId).toSet();

      // Delete from Firestore items that were removed locally
      final Set<String> deletedSyncIds =
          _lastKnownSyncIds.difference(currentSyncIds);
      for (final String syncId in deletedSyncIds) {
        await col.doc(syncId).delete();
      }
      _lastKnownSyncIds = currentSyncIds;

      if (items.isEmpty) return;

      // Upsert all current items in batches of 400
      const int chunkSize = 400;
      for (int i = 0; i < items.length; i += chunkSize) {
        final List<ShoppingListItem> chunk =
            items.sublist(i, min(i + chunkSize, items.length));
        final WriteBatch batch = _firestore.batch();

        for (final ShoppingListItem item in chunk) {
          batch.set(
            col.doc(item.syncId),
            <String, dynamic>{
              'syncId': item.syncId,
              'name': item.name,
              'quantity': item.quantity,
              'sourceRecipeId': item.sourceRecipeId,
              'sourceTitle': item.sourceTitle,
              'isChecked': item.isChecked,
              'createdAt': item.createdAt.millisecondsSinceEpoch,
              'checkedAt': item.checkedAt?.millisecondsSinceEpoch,
            },
            SetOptions(merge: true),
          );
        }

        await batch.commit();
      }
    } catch (e) {
      debugPrint('[ShoppingListSync] Push error: $e');
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
    bool anyChange = false;
    try {
      for (final DocumentChange<Map<String, dynamic>> change
          in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          final String? syncId = change.doc.data()?['syncId'] as String?;
          if (syncId != null) {
            await localRepo.deleteItemBySyncId(syncId, _currentUid ?? '');
            _lastKnownSyncIds.remove(syncId);
            anyChange = true;
          }
          continue;
        }

        final Map<String, dynamic>? data = change.doc.data();
        if (data == null) continue;

        try {
          await localRepo.saveItemFromCloud(data, _currentUid ?? '');
          final String? syncId = data['syncId'] as String?;
          if (syncId != null) _lastKnownSyncIds.add(syncId);
          anyChange = true;
        } catch (e) {
          debugPrint('[ShoppingListSync] Error parsing cloud item: $e');
        }
      }
    } finally {
      if (anyChange) await localRepo.emitAfterCloudUpdate();
      _isApplyingCloudUpdate = false;
    }
  }

  void dispose() {
    _localSub?.cancel();
    _stopSync();
  }
}
