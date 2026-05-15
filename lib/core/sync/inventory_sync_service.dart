import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/inventory/data/repositories/sqlite_inventory_repository.dart';
import '../../features/inventory/domain/entities/inventory_item.dart';
import '../network/connectivity_provider.dart';

class InventorySyncService {
  InventorySyncService(this.ref, this.localRepo) {
    _init();
  }

  final Ref ref;
  final SqliteInventoryRepository localRepo;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;

  String? _currentUid;
  bool _isOnline = false;
  bool _isSyncing = false;

  void _init() {
    // Initial State
    final initialUser = ref.read(authStateProvider).valueOrNull;
    if (initialUser != null) {
      _currentUid = initialUser.uid;
    }
    final initialOffline = ref.read(isOfflineProvider).valueOrNull ?? false;
    _isOnline = !initialOffline;

    if (_isOnline && _currentUid != null) {
      _startSync();
    }

    // Listen to Auth State
    ref.listen<AsyncValue<AppUser?>>(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        if (_currentUid != user.uid) {
          _currentUid = user.uid;
          _startSync();
        }
      } else {
        _stopSync();
      }
    });

    // Listen to Connectivity State
    ref.listen<AsyncValue<bool>>(isOfflineProvider, (previous, next) {
      final isOffline = next.valueOrNull ?? false;
      _isOnline = !isOffline;
      if (_isOnline && _currentUid != null) {
        _startSync();
      }
    });

    // Listen to Local DB changes to push
    localRepo.watchInventory().listen((_) {
      if (_isOnline && _currentUid != null) {
        _pushToCloud();
      }
    });
  }

  void _startSync() {
    if (_currentUid == null || !_isOnline) return;

    _firestoreSub?.cancel();
    _firestoreSub = firestore
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
  }

  Future<void> _pushToCloud() async {
    if (_isSyncing || _currentUid == null || !_isOnline) return;
    _isSyncing = true;
    try {
      final List<InventoryItem> localItems = await localRepo.getSyncableItems(0);

      for (final InventoryItem item in localItems) {
        final DocumentReference docRef = firestore
            .collection('users')
            .doc(_currentUid)
            .collection('inventory')
            .doc(item.syncId);

        final docSnap = await docRef.get();
        bool shouldPush = true;

        if (docSnap.exists) {
          final data = docSnap.data() as Map<String, dynamic>;
          final remoteUpdatedAt = data['updatedAt'] as int? ?? 0;
          if (remoteUpdatedAt >= item.updatedAt.millisecondsSinceEpoch) {
            shouldPush = false;
          }
        }

        if (shouldPush) {
          await docRef.set({
            'syncId': item.syncId,
            'barcode': item.barcode,
            'name': item.name,
            'brand': item.brand,
            'category': item.category,
            'quantity': item.quantity,
            'expiryDate': item.expiryDate?.millisecondsSinceEpoch,
            'imageUrl': item.imageUrl,
            'notes': item.notes,
            'createdAt': item.createdAt.millisecondsSinceEpoch,
            'updatedAt': item.updatedAt.millisecondsSinceEpoch,
            'isDeleted': item.isDeleted,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('Sync Push Error: \$e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _onCloudUpdate(QuerySnapshot<Map<String, dynamic>> snapshot) async {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        final data = change.doc.data();
        if (data == null) continue;

        try {
          final remoteItem = InventoryItem(
            id: 0, 
            syncId: data['syncId'] as String,
            barcode: data['barcode'] as String? ?? '',
            name: data['name'] as String,
            brand: data['brand'] as String?,
            category: data['category'] as String?,
            quantity: data['quantity'] as int? ?? 0,
            expiryDate: data['expiryDate'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['expiryDate'] as int)
                : null,
            imageUrl: data['imageUrl'] as String?,
            notes: data['notes'] as String?,
            createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int),
            isDeleted: data['isDeleted'] as bool? ?? false,
          );
          
          await localRepo.saveItemFromCloud(remoteItem);
        } catch (e) {
          debugPrint('Error parsing cloud item: \$e');
        }
      }
    }
  }

  void dispose() {
    _stopSync();
  }
}
