import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helpers para divergencias iOS/Android sin escribir `Platform.is*` manual.
///
/// Útil para:
/// - Pickers (Cupertino vs Material)
/// - Iconos del sistema (SF Symbols vs Material Symbols — Flutter usa Material por defecto)
/// - Scroll physics
/// - Animaciones de transición
class PlatformAdaptive {
  PlatformAdaptive._();

  /// `true` en iOS o macOS (donde aplican convenciones Cupertino).
  static bool get isCupertino {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  /// `true` en Android.
  static bool get isMaterial {
    if (kIsWeb) return true; // Default Material en web
    return Platform.isAndroid;
  }

  /// Scroll physics nativas (BouncingScrollPhysics iOS, ClampingScrollPhysics Android).
  static ScrollPhysics get scrollPhysics =>
      isCupertino ? const BouncingScrollPhysics() : const ClampingScrollPhysics();

  /// Cursor de texto color (iOS: blueish, Android: themed). Devuelve null
  /// para usar el default del theme.
  static Color? cursorColor(BuildContext context) =>
      isCupertino ? null : Theme.of(context).colorScheme.primary;

  /// Selecciona valor según plataforma.
  static T pick<T>({required T ios, required T android}) =>
      isCupertino ? ios : android;
}
