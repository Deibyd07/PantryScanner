import 'package:dio/dio.dart';

import '../../domain/entities/product_info.dart';
import '../mappers/openfoodfacts_category_mapper.dart';

/// Calls the public OpenFoodFacts v2 API to fetch product metadata for a
/// barcode. Returns `null` when the API does not recognize the product or
/// the network call fails — the caller should fall back to manual entry.
class OpenFoodFactsService {
  OpenFoodFactsService({Dio? dio, OpenFoodFactsCategoryMapper? mapper})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://world.openfoodfacts.org/api/v2',
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 6),
                headers: <String, String>{
                  'User-Agent':
                      'PantryScanner/0.1 (https://github.com/Deibyd07/PantryScanner)',
                },
              ),
            ),
        _mapper = mapper ?? const OpenFoodFactsCategoryMapper();

  final Dio _dio;
  final OpenFoodFactsCategoryMapper _mapper;

  Future<ProductInfo?> lookup(String barcode) async {
    if (barcode.isEmpty) return null;

    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(
        '/product/$barcode.json',
        queryParameters: <String, dynamic>{
          'fields':
              'code,product_name,product_name_es,brands,categories_tags,image_front_small_url,image_front_url,image_url',
        },
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) return null;
      final int status = (data['status'] as int?) ?? 0;
      if (status != 1) return null;

      final Map<String, dynamic>? product =
          data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final String name = _bestName(product);
      if (name.isEmpty) return null;

      return ProductInfo(
        barcode: barcode,
        name: name,
        brand: _firstNonEmpty(product['brands'] as String?),
        category: _mapper.resolve(_asStringList(product['categories_tags'])),
        imageUrl: _firstUsableImage(<String?>[
          product['image_front_small_url'] as String?,
          product['image_front_url'] as String?,
          product['image_url'] as String?,
        ]),
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String _bestName(Map<String, dynamic> product) {
    final String? es = (product['product_name_es'] as String?)?.trim();
    if (es != null && es.isNotEmpty) return es;
    final String? generic = (product['product_name'] as String?)?.trim();
    return generic ?? '';
  }

  String? _firstNonEmpty(String? raw) {
    if (raw == null) return null;
    final String first = raw.split(',').first.trim();
    return first.isEmpty ? null : first;
  }

  List<String>? _asStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return null;
  }

  String? _firstUsableImage(List<String?> candidates) {
    for (final String? url in candidates) {
      if (url != null && url.trim().isNotEmpty) return url;
    }
    return null;
  }
}
