import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated gradient background with floating particles used on auth screens.
class AuthGradientBackground extends StatefulWidget {
  const AuthGradientBackground({super.key, required this.child});
  final Widget child;

  @override
  State<AuthGradientBackground> createState() =>
      _AuthGradientBackgroundState();
}

class _AuthGradientBackgroundState extends State<AuthGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final double t = _ctrl.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8 + t * 0.4, 1.0 - t * 0.2),
              colors: <Color>[
                Color.lerp(
                  const Color(0xFF001F02),
                  const Color(0xFF002B02),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFF0D3B26),
                  const Color(0xFF1F7A5A),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFF145A3E),
                  const Color(0xFF0D3B26),
                  t,
                )!,
              ],
            ),
          ),
          child: child,
        );
      },
      child: Stack(
        children: <Widget>[
          // Floating particles
          ..._buildParticles(),
          // Actual content
          widget.child,
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final random = math.Random(42);
    return List<Widget>.generate(12, (int i) {
      final double left = random.nextDouble();
      final double top = random.nextDouble();
      final double size = 3.0 + random.nextDouble() * 5;
      final double opacity = 0.06 + random.nextDouble() * 0.1;
      final int durationMs = 4000 + random.nextInt(6000);

      return Positioned(
        left: left * 400,
        top: top * 800,
        child: _FloatingParticle(
          size: size,
          opacity: opacity,
          duration: Duration(milliseconds: durationMs),
        ),
      );
    });
  }
}

class _FloatingParticle extends StatefulWidget {
  const _FloatingParticle({
    required this.size,
    required this.opacity,
    required this.duration,
  });

  final double size;
  final double opacity;
  final Duration duration;

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * _ctrl.value),
          child: Opacity(
            opacity: widget.opacity * (0.4 + 0.6 * _ctrl.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
