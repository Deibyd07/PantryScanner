import 'package:dio/dio.dart';

import '../../domain/entities/product_info.dart';
import '../mappers/openfoodfacts_category_mapper.dart';

/// Consulta OpenFoodFacts v2 priorizando el endpoint colombiano (co.)
/// antes del global (world.). Retorna null si ninguno reconoce el producto.
class OpenFoodFactsService {
  OpenFoodFactsService({Dio? dio, OpenFoodFactsCategoryMapper? mapper})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                headers: <String, String>{
                  'User-Agent': 'Foodly/1.0 (Flutter; Android)',
                },
              ),
            ),
        _mapper = mapper ?? const OpenFoodFactsCategoryMapper();

  final Dio _dio;
  final OpenFoodFactsCategoryMapper _mapper;

  static const List<String> _hosts = <String>[
    'https://co.openfoodfacts.org',
    'https://world.openfoodfacts.org',
  ];

  static const String _fields =
      'code,product_name,product_name_es,brands,categories_tags,'
      'image_front_small_url,image_front_url,image_url';

  Future<ProductInfo?> lookup(String barcode) async {
    if (barcode.isEmpty) return null;

    for (final String host in _hosts) {
      final ProductInfo? result = await _fetchFrom(host, barcode);
      if (result != null) return result;
    }
    return null;
  }

  Future<ProductInfo?> _fetchFrom(String host, String barcode) async {
    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(
        '$host/api/v2/product/$barcode.json',
        queryParameters: <String, dynamic>{'fields': _fields},
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) return null;
      if ((data['status'] as int?) != 1) return null;

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
    if (raw is List) return raw.whereType<String>().toList(growable: false);
    return null;
  }

  String? _firstUsableImage(List<String?> candidates) {
    for (final String? url in candidates) {
      if (url != null && url.trim().isNotEmpty) return url;
    }
    return null;
  }
}
