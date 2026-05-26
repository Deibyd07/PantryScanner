/// Duraciones canónicas para animaciones.
///
/// Móvil-conscious: nada > 400ms en interacciones (excepto entradas hero).
/// La percepción de "snappy" es < 250ms; > 400ms se siente lento.
class AppDuration {
  AppDuration._();

  /// 100ms — micro feedback (tap highlight, color change).
  static const Duration instant = Duration(milliseconds: 100);

  /// 150ms — rápido (toggle, button press, scale).
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms — chips, switches, dropdown.
  static const Duration normal = Duration(milliseconds: 200);

  /// 250ms — image picker container, transitions menores.
  static const Duration medium = Duration(milliseconds: 250);

  /// 300ms — debounce típico (search, validación, password strength).
  static const Duration debounce = Duration(milliseconds: 300);

  /// 400ms — transiciones de page enter / cards.
  static const Duration slow = Duration(milliseconds: 400);

  /// 600ms — header animations al iniciar pantalla.
  static const Duration heroIn = Duration(milliseconds: 600);

  /// 800ms — entrada de hero con elastic curve.
  static const Duration heroLong = Duration(milliseconds: 800);

  /// 1200–1400ms — staggered list intro.
  static const Duration staggerShort = Duration(milliseconds: 1200);
  static const Duration staggerLong = Duration(milliseconds: 1400);

  /// 2000ms — loop shimmer del botón primario.
  static const Duration shimmerLoop = Duration(milliseconds: 2000);
}
