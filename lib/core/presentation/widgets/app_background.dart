import 'package:flutter/material.dart';

/// Full-screen background with food doodle pattern.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.overlayOpacity = 0.82,
    this.overlayColor = const Color(0xFFFFF8F7),
  });

  final double overlayOpacity;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          'assets/images/food_doodle_bg.png',
          fit: BoxFit.cover,
        ),
        ColoredBox(
          color: overlayColor.withValues(alpha: overlayOpacity),
        ),
      ],
    );
  }
}
