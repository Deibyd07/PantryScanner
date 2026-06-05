import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/repositories/sqlite_inventory_repository.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../../data/services/openfoodfacts_service.dart';
import '../../data/services/upcitemdb_service.dart';
import '../../domain/entities/product_info.dart';

/// Result of a product lookup attempt.
enum ProductLookupSource { cache, remote, notFound, offline }

class ProductLookupResult {
  const ProductLookupResult({required this.source, this.product});

  final ProductLookupSource source;
  final ProductInfo? product;

  bool get hasProduct => product != null;
}

final Provider<OpenFoodFactsService> openFoodFactsServiceProvider =
    Provider<OpenFoodFactsService>((Ref ref) => OpenFoodFactsService());

final Provider<UpcItemDbService> upcItemDbServiceProvider =
    Provider<UpcItemDbService>((Ref ref) => UpcItemDbService());

/// Cascade de búsqueda por código de barras:
///   1. Caché local SQLite (offline + instantáneo)
///   2. OpenFoodFacts Colombia (co.openfoodfacts.org)
///   3. OpenFoodFacts World (world.openfoodfacts.org)
///   4. UPCitemdb (mejor cobertura latinoamericana)
/// El primer resultado exitoso se guarda en caché SQLite.
final AutoDisposeFutureProviderFamily<ProductLookupResult, String>
    productLookupProvider = FutureProvider.autoDispose
        .family<ProductLookupResult, String>((ref, String barcode) async {
  if (barcode.isEmpty) {
    return const ProductLookupResult(source: ProductLookupSource.notFound);
  }

  final dynamic repo = ref.read(inventoryRepositoryProvider);

  // 1. Caché local
  if (!kIsWeb && repo is SqliteInventoryRepository) {
    final Map<String, dynamic>? cached = await repo.lookupCache(barcode);
    if (cached != null) {
      return ProductLookupResult(
        source: ProductLookupSource.cache,
        product: ProductInfo(
          barcode: barcode,
          name: (cached['name'] as String?) ?? '',
          brand: cached['brand'] as String?,
          category: cached['category'] as String?,
          imageUrl: cached['image_url'] as String?,
        ),
      );
    }
  }

  // 2 + 3. OpenFoodFacts (Colombia → World internamente)
  ProductInfo? remote =
      await ref.read(openFoodFactsServiceProvider).lookup(barcode);

  // 4. UPCitemdb como último fallback
  remote ??= await ref.read(upcItemDbServiceProvider).lookup(barcode);

  if (remote == null) {
    return const ProductLookupResult(source: ProductLookupSource.notFound);
  }

  // Guardar en caché para consultas futuras offline
  if (!kIsWeb && repo is SqliteInventoryRepository) {
    await repo.cacheProductMetadata(
      barcode: remote.barcode,
      name: remote.name,
      brand: remote.brand,
      category: remote.category,
      imageUrl: remote.imageUrl,
    );
  }

  return ProductLookupResult(
    source: ProductLookupSource.remote,
    product: remote,
  );
});
