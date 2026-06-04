import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncStatus { idle, syncing, error }

/// Número de operaciones de sync en vuelo. Se usa un contador para que
/// inventory y shopping-list puedan sincronizar en paralelo sin pisarse.
final StateProvider<int> _syncCountProvider =
    StateProvider<int>((Ref ref) => 0);

/// Estado de sync derivado del contador: syncing mientras haya ops activas.
final Provider<SyncStatus> syncStatusProvider = Provider<SyncStatus>((ref) {
  final int count = ref.watch(_syncCountProvider);
  return count > 0 ? SyncStatus.syncing : SyncStatus.idle;
});

/// Registra el inicio de una operación de sync. Devuelve una función que
/// debe llamarse cuando la op termina (éxito o error).
void syncBegin(Ref ref) {
  ref.read(_syncCountProvider.notifier).update((int n) => n + 1);
}

void syncEnd(Ref ref) {
  ref.read(_syncCountProvider.notifier).update((int n) => (n - 1).clamp(0, 999));
}
