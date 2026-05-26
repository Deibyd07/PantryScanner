import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

/// Indicador animado de fortaleza de contraseña (0–100%).
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  double get strength {
    if (password.isEmpty) return 0;
    double s = 0;
    if (password.length >= 8) s += 0.25;
    if (password.length >= 12) s += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) s += 0.25;
    if (RegExp(r'[!@#\$%\^&\*\(\)\-_=\+\[\]\{\};:,\.<>\?/\\|`~]')
        .hasMatch(password)) {
      s += 0.15;
    }
    return s.clamp(0.0, 1.0);
  }

  Color get _color {
    final double s = strength;
    if (s <= 0.25) return AppColors.dangerStrong;
    if (s <= 0.5) return AppColors.warningSoft;
    if (s <= 0.75) return AppColors.warningStrong;
    return AppColors.successStrong;
  }

  String get _label {
    final double s = strength;
    if (s <= 0) return '';
    if (s <= 0.25) return 'Débil';
    if (s <= 0.5) return 'Regular';
    if (s <= 0.75) return 'Buena';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final PaletteSpec p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.brXs,
            child: SizedBox(
              height: 4,
              child: Stack(
                children: <Widget>[
                  Container(color: p.outline.withValues(alpha: 0.5)),
                  AnimatedFractionallySizedBox(
                    duration: AppDuration.debounce,
                    curve: Curves.easeOut,
                    widthFactor: strength,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: AppRadius.brXs,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedDefaultTextStyle(
            duration: AppDuration.normal,
            style: AppTypography.labelXs.copyWith(color: _color),
            child: Text(_label),
          ),
        ],
      ),
    );
  }
}
