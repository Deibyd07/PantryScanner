import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

class InventoryInsightsCard extends StatelessWidget {
  const InventoryInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.ml),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXxl,
        boxShadow: AppElevation.modal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: AppRadius.brMdPlus,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Resumen inteligente',
                      style: AppTypography.headingSm.copyWith(color: p.textBody),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '3 productos vencen en menos de 48 h',
                      style: AppTypography.bodyXs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: p.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              const Expanded(
                child: _MetricTile(
                  value: '12%',
                  label: 'Desperdicio',
                  icon: Icons.trending_down_rounded,
                  color: AppColors.warningStrong,
                ),
              ),
              _VerticalDivider(color: p.divider),
              Expanded(
                child: _MetricTile(
                  value: '84',
                  label: 'Productos',
                  icon: Icons.inventory_2_outlined,
                  color: p.brandPrimary,
                ),
              ),
              _VerticalDivider(color: p.divider),
              const Expanded(
                child: _MetricTile(
                  value: '3',
                  label: 'Por vencer',
                  icon: Icons.timer_outlined,
                  color: AppColors.dangerStrong,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: color,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return Column(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.brMs,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.headingLg.copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.labelTab.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
