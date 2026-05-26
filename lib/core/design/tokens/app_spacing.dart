import 'package:flutter/widgets.dart';

/// Escala de espaciado de 4pt — usar SIEMPRE en lugar de magic numbers.
///
/// Regla: si necesitas un valor que no está aquí, primero pregúntate si
/// realmente lo necesitas. Si la respuesta es sí, agrégalo aquí.
class AppSpacing {
  AppSpacing._();

  /// 2pt — micro (separación entre line-height y elemento).
  static const double xxs = 2;

  /// 4pt — extra small (gap entre icono y label de su mismo elemento).
  static const double xs = 4;

  /// 8pt — small (separación dentro de un componente).
  static const double sm = 8;

  /// 12pt — medium-small (compactos: chips, badges).
  static const double ms = 12;

  /// 14pt — intermedio entre ms y md (paddings de containers grandes).
  static const double mdPlus = 14;

  /// 16pt — medium (padding estándar de componentes, gap entre items).
  static const double md = 16;

  /// 20pt — medium-large.
  static const double ml = 20;

  /// 24pt — large (padding horizontal de pantallas, gap entre secciones).
  static const double lg = 24;

  /// 32pt — extra large (separación entre bloques grandes).
  static const double xl = 32;

  /// 48pt — huge (hero, big sections).
  static const double xxl = 48;

  /// 64pt — massive (rarely used — solo hero verticales).
  static const double xxxl = 64;

  // ──────────────────────────────────────────────────────────────────────────
  // SizedBox helpers — para usar inline en columnas/filas sin escribir tanto.
  // ──────────────────────────────────────────────────────────────────────────

  static const SizedBox gapXxs = SizedBox(height: xxs, width: xxs);
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMs = SizedBox(height: ms, width: ms);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapMl = SizedBox(height: ml, width: ml);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  // ──────────────────────────────────────────────────────────────────────────
  // EdgeInsets helpers más comunes.
  // ──────────────────────────────────────────────────────────────────────────

  /// Padding horizontal estándar de pantalla (24pt).
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);

  /// Padding de card estándar (16pt all).
  static const EdgeInsets cardAll = EdgeInsets.all(md);

  /// Padding de card large (20pt all).
  static const EdgeInsets cardAllLg = EdgeInsets.all(ml);
}
