import 'package:flutter/services.dart';

/// API semántica de feedback háptico, multiplataforma.
///
/// Usa HapticFeedback de Flutter (mapeo automático iOS/Android):
/// - iOS: UIImpactFeedbackGenerator + UISelectionFeedbackGenerator + UINotificationFeedbackGenerator
/// - Android: HapticFeedbackConstants
///
/// **Reglas de uso:**
/// - `tap` — confirmar interacción ligera (chip toggle, switch).
/// - `select` — selección de item discreta (picker, segmento).
/// - `confirm` — acción importante completada (guardar producto).
/// - `success` — éxito final (registro creado, password reset enviado).
/// - `warning` — atención requerida (validación fallida).
/// - `error` — error destructivo (eliminar, error de red).
/// - `heavy` — para gestos importantes (escaneo exitoso, drop).
///
/// **No abusar.** Háptica excesiva = fatiga del usuario.
class AppHaptics {
  AppHaptics._();

  /// Feedback ligero — selección/toggle (1ms suave).
  static Future<void> tap() => HapticFeedback.selectionClick();

  /// Selección de item de una lista discreta.
  static Future<void> select() => HapticFeedback.selectionClick();

  /// Confirmación estándar de acción (button tap importante, save).
  static Future<void> confirm() => HapticFeedback.mediumImpact();

  /// Éxito final (registro, escaneo válido).
  static Future<void> success() => HapticFeedback.lightImpact();

  /// Advertencia / validación fallida.
  static Future<void> warning() => HapticFeedback.mediumImpact();

  /// Error destructivo o rechazado.
  static Future<void> error() => HapticFeedback.heavyImpact();

  /// Impacto fuerte (escaneo de código exitoso, drop, drag end).
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Click ligero — para feedback de scroll, scrub, etc.
  static Future<void> light() => HapticFeedback.lightImpact();
}
