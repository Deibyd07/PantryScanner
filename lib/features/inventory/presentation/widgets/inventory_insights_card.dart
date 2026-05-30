import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_providers.dart';

class InventoryInsightsCard extends ConsumerWidget {
  const InventoryInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AsyncValue<List<InventoryItem>> asyncItems =
        ref.watch(inventoryItemsProvider);

    final _InsightsMetrics metrics = asyncItems.maybeWhen(
      data: _InsightsMetrics.fromItems,
      orElse: () => const _InsightsMetrics(),
    );

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
          Text(
            'Resumen inteligente',
            style: AppTypography.headingSm.copyWith(color: p.textBody),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _buildSubtitle(metrics),
            style: AppTypography.bodyXs.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: p.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricTile(
                  value: metrics.expiredCount.toString(),
                  label: 'Vencidos',
                  icon: Icons.error_outline_rounded,
                  color: AppColors.dangerStrong,
                ),
              ),
              _VerticalDivider(color: p.divider),
              Expanded(
                child: _MetricTile(
                  value: metrics.totalCount.toString(),
                  label: 'Productos',
                  icon: Icons.inventory_2_outlined,
                  color: p.brandPrimary,
                ),
              ),
              _VerticalDivider(color: p.divider),
              Expanded(
                child: _MetricTile(
                  value: metrics.expiringSoonCount.toString(),
                  label: 'Por vencer',
                  icon: Icons.timer_outlined,
                  color: AppColors.warningStrong,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(_InsightsMetrics m) {
    if (m.totalCount == 0) {
      return 'Aún no tienes productos en tu despensa';
    }
    if (m.expiringSoonCount == 0 && m.expiredCount == 0) {
      return 'Todo en orden: nada por vencer pronto';
    }
    if (m.expiredCount > 0 && m.expiringSoonCount > 0) {
      return '${m.expiredCount} vencidos · ${m.expiringSoonCount} por vencer pronto';
    }
    if (m.expiredCount > 0) {
      return '${m.expiredCount} ${m.expiredCount == 1 ? "producto vencido" : "productos vencidos"}';
    }
    return '${m.expiringSoonCount} ${m.expiringSoonCount == 1 ? "producto vence" : "productos vencen"} pronto';
  }
}

class _InsightsMetrics {
  const _InsightsMetrics({
    this.totalCount = 0,
    this.expiringSoonCount = 0,
    this.expiredCount = 0,
  });

  factory _InsightsMetrics.fromItems(List<InventoryItem> items) {
    int expiring = 0;
    int expired = 0;
    for (final InventoryItem item in items) {
      switch (item.status) {
        case ProductStatus.expiringSoon:
          expiring++;
          break;
        case ProductStatus.expired:
          expired++;
          break;
        case ProductStatus.normal:
        case ProductStatus.outOfStock:
          break;
      }
    }
    return _InsightsMetrics(
      totalCount: items.length,
      expiringSoonCount: expiring,
      expiredCount: expired,
    );
  }

  final int totalCount;
  final int expiringSoonCount;
  final int expiredCount;
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
