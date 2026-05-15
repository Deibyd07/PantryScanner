import 'package:flutter/material.dart';

class InventoryTokens {
  static const Color bg = Color(0xFFFBFAEE);
  static const Color bgMuted = Color(0xFFF2F1E5);
  static const Color primary = Color(0xFF002B02);
  static const Color secondary = Color(0xFF4A6549);
  static const Color tertiary = Color(0xFF790007);
  static const Color accentContainer = Color(0xFF154212);
  static const Color accentOnContainer = Color(0xFF7EAF73);
  static const Color outline = Color(0xFFC2C9BB);
  static const Color textMuted = Color(0xFF72796E);
  static const Color textBody = Color(0xFF42493E);
}
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.02),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevMed => <BoxShadow>[
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.03),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevBrand => <BoxShadow>[
    BoxShadow(
      color: brand.withValues(alpha: 0.30),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
