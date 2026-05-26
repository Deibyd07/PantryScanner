import 'package:flutter/widgets.dart';

/// Breakpoints para layout responsivo.
///
/// PantryScanner es principalmente phone-first (utility móvil), pero un
/// foldable/tablet no debería romperse: ancho máximo de cards en tablets.
class AppBreakpoints {
  AppBreakpoints._();

  /// < 360pt — pantallas extra pequeñas (legacy Android, iPhone SE 1ra gen).
  static const double phoneXs = 360;

  /// < 600pt — phone estándar.
  static const double phone = 600;

  /// 600-840pt — tablet pequeña / foldable abierto.
  static const double tablet = 840;

  /// > 840pt — tablet grande / desktop.
  static const double desktop = 1200;

  /// Ancho máximo de contenido (centrado) en pantallas grandes.
  static const double maxContentWidth = 480;

  /// Helpers (sin tener que llamar MediaQuery en cada widget).

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phone;

  static bool isTablet(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    return w >= phone && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}
