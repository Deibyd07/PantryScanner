import 'package:flutter/material.dart';

import '../platform/app_haptics.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_duration.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Botón primario con efecto shimmer animado.
///
/// CTA principal de la app — usado en login, registro, guardado de productos.
/// Forma parte del lenguaje visual de marca: gradiente rojo + halo + shimmer.
///
/// **Comportamiento:**
/// - Dispara haptic feedback `confirm` al tap.
/// - Loading state reemplaza el contenido por un spinner blanco.
/// - Si `onPressed` es null, el botón queda inactivo (sin tap, sin haptic).
class BrandGradientButton extends StatefulWidget {
  const BrandGradientButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.height = 56,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double height;

  @override
  State<BrandGradientButton> createState() => _BrandGradientButtonState();
}

class _BrandGradientButtonState extends State<BrandGradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: AppDuration.shimmerLoop,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _shimmer.value, 0),
              end: Alignment(1.0 + 2.0 * _shimmer.value, 0),
              colors: AppColors.shimmerStops,
              stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            boxShadow: AppElevation.primaryButton(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed == null
                  ? null
                  : () {
                      AppHaptics.confirm();
                      widget.onPressed!();
                    },
              borderRadius: AppRadius.brLg,
              splashColor: Colors.white.withValues(alpha: 0.15),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (widget.icon != null) ...<Widget>[
                            Icon(widget.icon, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: AppTypography.buttonLg.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
