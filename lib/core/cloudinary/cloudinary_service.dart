import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Sube imágenes de productos a Cloudinary usando un upload preset unsigned.
/// No requiere API secret — el preset unsigned es seguro para uso desde móvil.
class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'dobttsg2q';
  static const String _uploadPreset = 'pantryscanner_uploads';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  final Dio _dio = Dio();

  static const String _productsFolder = 'pantryscanner/products';
  static const String _recipesFolder = 'pantryscanner/recipes';

  /// Sube [file] a Cloudinary y devuelve la URL segura (https).
  ///
  /// [userId] → imágenes de producto, aisladas en carpeta por usuario.
  /// Omitir [userId] → imágenes compartidas (recetas).
  /// [onProgress] recibe valores de 0.0 a 1.0 durante la subida.
  Future<String> uploadImage(
    File file, {
    String? userId,
    void Function(double progress)? onProgress,
  }) async {
    final String folder =
        userId != null ? '$_productsFolder/$userId' : _recipesFolder;

    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': _uploadPreset,
      'folder': folder,
    });

    final Response<Map<String, dynamic>> response =
        await _dio.post<Map<String, dynamic>>(
      _uploadUrl,
      data: formData,
      onSendProgress: onProgress == null
          ? null
          : (int sent, int total) {
              if (total > 0) onProgress(sent / total);
            },
    );

    final String? secureUrl = response.data?['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary no devolvió una URL válida');
    }

    debugPrint('[Cloudinary] Imagen subida: $secureUrl');
    return secureUrl;
  }
}
