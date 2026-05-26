import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sistema de sombras tokenizado.
///
/// En lugar de hardcodear BoxShadow por todos lados, define semantically:
/// - `card` — sombra sutil para cards en superficies claras
/// - `cardStatus` — sombra tintada por color de estado (producto, alerta)
/// - `modal` — sombra fuerte para modales, popups
/// - `fab` — sombra de FAB elevado (botón scan flotante)
/// - `hero` — sombra para iconos hero (logo en gradiente)
///
/// En dark mode las sombras son casi invisibles — la elevación se simula
/// con superficies tonalmente más claras (ver AppColors.dark.surfaceHigh).
class AppElevation {
  AppElevation._();

  /// Card estándar — sombra muy sutil.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// Card con tinte del status color (productos en inventario).
  /// Pasar el `statusColor` como argumento.
  static List<BoxShadow> cardStatus(Color statusColor, {bool dimmed = false}) {
    final double alpha = dimmed ? 0.04 : 0.08;
    return <BoxShadow>[
      BoxShadow(
        color: statusColor.withValues(alpha: alpha),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      const BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
  }

  /// Popup / dropdown — sombra mediana.
  static const List<BoxShadow> popup = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Modal / dialog / large card hero — sombra prominente.
  static const List<BoxShadow> modal = <BoxShadow>[
    BoxShadow(
      color: Color(0x30000000), // 19% black
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x12C0392B), // tinte de marca sutil
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  /// FAB elevado (botón scan central del bottom nav).
  static List<BoxShadow> fabBrand({double alpha = 0.45}) => <BoxShadow>[
        BoxShadow(
          color: AppColors.brandPrimary.withValues(alpha: alpha),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        const BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];

  /// Icono hero blanco sobre gradiente (logos del split-hero).
  static const List<BoxShadow> heroIcon = <BoxShadow>[
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  /// Botón primario shimmer (CTA principal).
  static List<BoxShadow> primaryButton({double alpha = 0.35}) => <BoxShadow>[
        BoxShadow(
          color: AppColors.brandPrimary.withValues(alpha: alpha),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Sombra superior para barras inferiores (bottom nav).
  static const List<BoxShadow> bottomBar = <BoxShadow>[
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 20,
      offset: Offset(0, -6),
    ),
  ];
}
