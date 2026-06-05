import 'package:dio/dio.dart';

import '../../domain/entities/product_info.dart';

/// Consulta la API gratuita de UPCitemdb (100 req/día por IP).
/// Mejor cobertura de productos latinoamericanos que OpenFoodFacts.
/// Se usa como fallback cuando OpenFoodFacts no encuentra el producto.
class UpcItemDbService {
  UpcItemDbService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.upcitemdb.com/prod/trial',
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                headers: <String, String>{
                  'User-Agent': 'Foodly/1.0 (Flutter; Android)',
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Future<ProductInfo?> lookup(String barcode) async {
    if (barcode.isEmpty) return null;

    try {
      final Response<Map<String, dynamic>> response =
          await _dio.get<Map<String, dynamic>>(
        '/lookup',
        queryParameters: <String, dynamic>{'upc': barcode},
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) return null;
      if ((data['code'] as String?) != 'OK') return null;

      final List<dynamic>? items = data['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) return null;

      final Map<String, dynamic>? item = items.first as Map<String, dynamic>?;
      if (item == null) return null;

      final String title = ((item['title'] as String?) ?? '').trim();
      if (title.isEmpty) return null;

      final String? imageUrl = _firstImage(item['images']);

      return ProductInfo(
        barcode: barcode,
        name: title,
        brand: _nonEmpty(item['brand'] as String?),
        category: _mapCategory(item['category'] as String?),
        imageUrl: imageUrl,
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _nonEmpty(String? raw) {
    if (raw == null) return null;
    final String v = raw.trim();
    return v.isEmpty ? null : v;
  }

  String? _firstImage(dynamic images) {
    if (images is List && images.isNotEmpty) {
      final String? url = images.first as String?;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    }
    return null;
  }

  // Mapea las categorías en inglés de UPCitemdb a las internas de Foodly.
  static const Map<String, String> _keywords = <String, String>{
    'dairy': 'Lácteos',
    'milk': 'Lácteos',
    'cheese': 'Lácteos',
    'yogurt': 'Lácteos',
    'meat': 'Carnes',
    'poultry': 'Carnes',
    'seafood': 'Carnes',
    'fish': 'Carnes',
    'sausage': 'Carnes',
    'fruit': 'Frutas y verduras',
    'vegetable': 'Frutas y verduras',
    'produce': 'Frutas y verduras',
    'canned': 'Enlatados',
    'preserved': 'Enlatados',
    'beverage': 'Bebidas',
    'drink': 'Bebidas',
    'water': 'Bebidas',
    'juice': 'Bebidas',
    'coffee': 'Bebidas',
    'tea': 'Bebidas',
    'soda': 'Bebidas',
    'snack': 'Snacks',
    'chip': 'Snacks',
    'cookie': 'Snacks',
    'candy': 'Snacks',
    'chocolate': 'Snacks',
    'cracker': 'Snacks',
    'cereal': 'Cereales',
    'pasta': 'Cereales',
    'rice': 'Cereales',
    'bread': 'Cereales',
    'grain': 'Cereales',
    'flour': 'Cereales',
    'sauce': 'Condimentos',
    'spice': 'Condimentos',
    'oil': 'Condimentos',
    'vinegar': 'Condimentos',
    'condiment': 'Condimentos',
    'seasoning': 'Condimentos',
    'cleaning': 'Limpieza',
    'detergent': 'Limpieza',
    'soap': 'Limpieza',
    'personal care': 'Higiene',
    'hygiene': 'Higiene',
    'shampoo': 'Higiene',
    'toothpaste': 'Higiene',
  };

  String? _mapCategory(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final String lower = raw.toLowerCase();
    for (final MapEntry<String, String> entry in _keywords.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }
}
