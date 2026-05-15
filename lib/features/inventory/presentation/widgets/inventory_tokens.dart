import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PantryScanner Design Tokens
// Paleta inspirada en sábana de cuadros rojos y blancos:
//   Rojo cereza vibrante · Blanco cálido rosado · Carmesí profundo · Coral
// ─────────────────────────────────────────────────────────────────────────────
class InventoryTokens {
  // Backgrounds — blanco cálido con toque rosado
  static const Color bg       = Color(0xFFFFF8F7); // cálido casi blanco
  static const Color bgMuted  = Color(0xFFFFEDEB); // rosa muy suave

  // Brand — rojo cereza vibrante (del cuadro)
  static const Color primary          = Color(0xFFC0392B); // rojo cereza profundo
  static const Color secondary        = Color(0xFFE74C3C); // rojo vibrante
  static const Color tertiary         = Color(0xFFFF6B6B); // coral suave (warnings)

  // Accent buttons / FAB — carmesí intenso
  static const Color accentContainer    = Color(0xFFC0392B); // botón FAB
  static const Color accentOnContainer  = Color(0xFFFFD6D2); // texto sobre FAB

  // Borders & dividers
  static const Color outline = Color(0xFFFFBDBA); // rosa-rojo suave

  // Text
  static const Color textMuted = Color(0xFFA04040); // rojo apagado
  static const Color textBody  = Color(0xFF4A1010); // granate oscuro
}
