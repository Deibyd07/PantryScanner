import 'package:flutter/material.dart';

/// Full-screen background with food doodle pattern.
///
/// Renders the dark doodle texture and then overlays a very
/// translucent white wash so UI cards pop on top while the
/// doodles remain clearly visible between them.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.overlayOpacity = 0.82,
    this.overlayColor = const Color(0xFFFFF8F7), // cálido rosado
  });

  final double overlayOpacity;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // ── Doodle texture ───────────────────────────────────────────────────
        Image.asset(
          'assets/images/food_doodle_bg.png',
          fit: BoxFit.cover,
        ),
        // ── Very light wash — just enough to show UI contrast ────────────────
        ColoredBox(
          color: overlayColor.withValues(alpha: overlayOpacity),
        ),
      ],
    );
  }
}
