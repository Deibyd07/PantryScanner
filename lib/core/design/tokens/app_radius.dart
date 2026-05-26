import 'package:flutter/widgets.dart';

/// Escala de border radius.
class AppRadius {
  AppRadius._();

  /// 4pt — micro (progress bars, hairline elements).
  static const double xs = 4;

  /// 8pt — pequeño (badges pequeños).
  static const double sm = 8;

  /// 10pt — chips compactos, mini-iconos.
  static const double ms = 10;

  /// 12pt — botones secundarios, dropdowns, back buttons.
  static const double md = 12;

  /// 14pt — botones primarios (legacy del proyecto).
  static const double mdPlus = 14;

  /// 16pt — inputs, botones grandes, cards compactos.
  static const double lg = 16;

  /// 20pt — cards, popups, dialogs.
  static const double xl = 20;

  /// 24pt — cards hero, large containers.
  static const double xxl = 24;

  /// 36pt — sheet top corners (modal del split-hero pattern).
  static const double xxxl = 36;

  /// 999pt — pill / capsule (chips, status badges, progress fill).
  static const double pill = 999;

  // ──────────────────────────────────────────────────────────────────────────
  // BorderRadius helpers prebuilt (evita instanciar en cada build).
  // ──────────────────────────────────────────────────────────────────────────

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMs = BorderRadius.all(Radius.circular(ms));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brMdPlus = BorderRadius.all(Radius.circular(mdPlus));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  /// Sheet superior redondeado (split-hero card).
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xxxl),
  );
}
