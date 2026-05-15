import 'package:flutter/material.dart';

class CheckeredPattern extends StatelessWidget {
  const CheckeredPattern({
    super.key,
    required this.color,
    this.squareSize = 30.0,
  });

  final Color color;
  final double squareSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckeredPatternPainter(
        color: color,
        squareSize: squareSize,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CheckeredPatternPainter extends CustomPainter {
  const _CheckeredPatternPainter({
    required this.color,
    required this.squareSize,
  });

  final Color color;
  final double squareSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        if (((x / squareSize).floor() % 2 == 0) == ((y / squareSize).floor() % 2 == 0)) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckeredPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.squareSize != squareSize;
  }
}
