import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Emits true when there is NO internet connection, false when connected.
// ─────────────────────────────────────────────────────────────────────────────

/// Reactive stream that maps connectivity events to an offline boolean.
/// `true`  → device is offline (no network interfaces available)
/// `false` → device is online  (at least one interface is active)
final StreamProvider<bool> isOfflineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (List<ConnectivityResult> results) =>
            results.isEmpty ||
            results.every(
              (ConnectivityResult r) => r == ConnectivityResult.none,
            ),
      );
});
