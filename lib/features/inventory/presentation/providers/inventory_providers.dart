import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/save_inventory_item_usecase.dart';
import '../../domain/usecases/watch_inventory_items_usecase.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>(
  (Ref<AppDatabase> ref) {
    final AppDatabase db = AppDatabase();
    ref.onDispose(db.close);
    return db;
  },
);

final Provider<InventoryRepository> inventoryRepositoryProvider =
    Provider<InventoryRepository>(
  (Ref<InventoryRepository> ref) {
    final AppDatabase database = ref.watch(appDatabaseProvider);
    return InventoryRepositoryImpl(database);
  },
);

final Provider<WatchInventoryItemsUseCase> watchInventoryItemsUseCaseProvider =
    Provider<WatchInventoryItemsUseCase>(
  (Ref<WatchInventoryItemsUseCase> ref) {
    final InventoryRepository repository = ref.watch(inventoryRepositoryProvider);
    return WatchInventoryItemsUseCase(repository);
  },
);

final Provider<SaveInventoryItemUseCase> saveInventoryItemUseCaseProvider =
    Provider<SaveInventoryItemUseCase>(
  (Ref<SaveInventoryItemUseCase> ref) {
    final InventoryRepository repository = ref.watch(inventoryRepositoryProvider);
    return SaveInventoryItemUseCase(repository);
  },
);

final AutoDisposeStreamProvider<List<InventoryItem>> inventoryItemsProvider =
    StreamProvider.autoDispose<List<InventoryItem>>(
  (Ref ref) {
    final WatchInventoryItemsUseCase useCase = ref.watch(watchInventoryItemsUseCaseProvider);
    return useCase();
  },
);
