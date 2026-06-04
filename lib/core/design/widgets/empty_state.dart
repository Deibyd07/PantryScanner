import 'package:flutter/material.dart';

import '../platform/app_haptics.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_duration.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Widget genérico de estado vacío — PantryScanner Design System.
///
/// Muestra una ilustración (icono), título, descripción y un botón CTA
/// opcional con gradiente de marca. Incluye micro-animación de entrada
/// (fade + slide-up) para una experiencia visual premium.
///
/// **Uso básico:**
/// ```dart
/// EmptyState(
///   icon: Icons.inventory_2_outlined,
///   title: 'Tu despensa está vacía',
///   description: '¡Comienza escaneando tu primer producto!',
///   ctaText: 'Escanear mi primer producto',
///   ctaIcon: Icons.qr_code_scanner_rounded,
///   onCtaPressed: () => context.push(AppRoutes.scanner),
/// )
/// ```
class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaText,
    this.ctaIcon,
    this.onCtaPressed,
    this.iconColor,
  });

  /// Ícono de la ilustración central.
  final IconData icon;

  /// Título principal en negrita.
  final String title;

  /// Descripción de apoyo, puede incluir más contexto.
  final String description;

  /// Texto del botón CTA (opcional). Si es null, no se renderiza el botón.
  final String? ctaText;

  /// Ícono del botón CTA (opcional).
  final IconData? ctaIcon;

  /// Callback al presionar el botón CTA.
  final VoidCallback? onCtaPressed;

  /// Color personalizado del icono central (por defecto: brandPrimary con opacidad).
  final Color? iconColor;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDuration.medium,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ── Ilustración ──────────────────────────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: widget.iconColor != null
                        ? widget.iconColor!.withValues(alpha: 0.1)
                        : p.brandTintSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 48,
                      color: widget.iconColor ??
                          p.brandPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.ml),

                // ── Título ───────────────────────────────────────────────────
                Text(
                  widget.title,
                  style: AppTypography.headingMd.copyWith(
                    color: p.textBody,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Descripción ───────────────────────────────────────────────
                Text(
                  widget.description,
                  style: AppTypography.bodyMd.copyWith(
                    color: p.textMuted,
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),

                // ── Botón CTA (opcional) ─────────────────────────────────────
                if (widget.ctaText != null && widget.onCtaPressed != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  _EmptyStateCta(
                    label: widget.ctaText!,
                    icon: widget.ctaIcon,
                    onPressed: widget.onCtaPressed!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Botón CTA privado — gradiente de marca con efecto shimmer suave.
// ──────────────────────────────────────────────────────────────────────────────
class _EmptyStateCta extends StatefulWidget {
  const _EmptyStateCta({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  State<_EmptyStateCta> createState() => _EmptyStateCtaState();
}

class _EmptyStateCtaState extends State<_EmptyStateCta>
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
          height: 52,
          decoration: BoxDecoration(
            borderRadius: AppRadius.brLg,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _shimmer.value, 0),
              end: Alignment(1.0 + 2.0 * _shimmer.value, 0),
              colors: AppColors.shimmerStops,
              stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.brandPrimary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AppHaptics.confirm();
                widget.onPressed();
              },
              borderRadius: AppRadius.brLg,
              splashColor: Colors.white.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.icon != null) ...<Widget>[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      widget.label,
                      style: AppTypography.buttonMd.copyWith(
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
