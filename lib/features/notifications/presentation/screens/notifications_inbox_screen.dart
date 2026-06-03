import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AsyncValue<List<InventoryItem>> asyncItems =
        ref.watch(inventoryItemsProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: asyncItems.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            'No se pudieron cargar las notificaciones',
            style: AppTypography.bodyMd.copyWith(color: p.textMuted),
          ),
        ),
        data: (List<InventoryItem> items) {
          final List<InventoryItem> expired = items
              .where((InventoryItem i) => i.status == ProductStatus.expired)
              .toList()
            ..sort((a, b) =>
                (b.expiryDate ?? DateTime(0)).compareTo(a.expiryDate ?? DateTime(0)));
          final List<InventoryItem> expiringSoon = items
              .where((InventoryItem i) =>
                  i.status == ProductStatus.expiringSoon)
              .toList()
            ..sort((a, b) =>
                (a.expiryDate ?? DateTime(9999)).compareTo(b.expiryDate ?? DateTime(9999)));
          final List<InventoryItem> lowStock = items
              .where((InventoryItem i) =>
                  i.isLowStock && i.status != ProductStatus.expired)
              .toList()
            ..sort((a, b) => a.quantity.compareTo(b.quantity));

          final int total =
              expired.length + expiringSoon.length + lowStock.length;

          return RefreshIndicator(
            color: p.brandPrimary,
            onRefresh: () async {
              ref.invalidate(inventoryItemsProvider);
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                _InboxHero(
                  total: total,
                  expired: expired.length,
                  expiringSoon: expiringSoon.length,
                  lowStock: lowStock.length,
                ),
                if (total == 0)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyInbox(palette: p),
                  )
                else ...<Widget>[
                  if (expired.isNotEmpty) ...<Widget>[
                    _SectionHeader(
                      title: 'Vencidos',
                      caption: 'Retíralos de tu despensa',
                      color: AppColors.dangerStrong,
                      count: expired.length,
                    ),
                    _ItemsList(
                      items: expired,
                      accent: AppColors.dangerStrong,
                    ),
                  ],
                  if (expiringSoon.isNotEmpty) ...<Widget>[
                    _SectionHeader(
                      title: 'Por vencer pronto',
                      caption: 'Consúmelos en los próximos días',
                      color: AppColors.warningStrong,
                      count: expiringSoon.length,
                    ),
                    _ItemsList(
                      items: expiringSoon,
                      accent: AppColors.warningStrong,
                    ),
                  ],
                  if (lowStock.isNotEmpty) ...<Widget>[
                    _SectionHeader(
                      title: 'Stock bajo',
                      caption: 'Pronto necesitarás reponerlos',
                      color: p.brandPrimary,
                      count: lowStock.length,
                    ),
                    _ItemsList(
                      items: lowStock,
                      accent: p.brandPrimary,
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxl),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card: gradient + back button + title + summary metric chips
// ─────────────────────────────────────────────────────────────────────────────
class _InboxHero extends StatelessWidget {
  const _InboxHero({
    required this.total,
    required this.expired,
    required this.expiringSoon,
    required this.lowStock,
  });

  final int total;
  final int expired;
  final int expiringSoon;
  final int lowStock;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.xxxl),
            bottomRight: Radius.circular(AppRadius.xxxl),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPad + AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    context.pop();
                  },
                ),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'Configurar alertas',
                  onTap: () {
                    AppHaptics.tap();
                    context.push(AppRoutes.notificationSettings);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notificaciones',
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? 'Todo en orden por ahora'
                  : total == 1
                      ? '1 producto requiere tu atención'
                      : '$total productos requieren tu atención',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    label: 'Vencidos',
                    count: expired,
                    icon: Icons.error_outline_rounded,
                    accent: const Color(0xFFFFCDD2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Por vencer',
                    count: expiringSoon,
                    icon: Icons.timer_outlined,
                    accent: const Color(0xFFFFE0B2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Stock bajo',
                    count: lowStock,
                    icon: Icons.inventory_2_outlined,
                    accent: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: child) : child;
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool hasItems = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.ms,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: hasItems ? 0.16 : 0.08),
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: Colors.white.withValues(alpha: hasItems ? 0.32 : 0.14),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: AppSpacing.xxs + 1),
          Text(
            '$count',
            style: AppTypography.headingMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.caption,
    required this.color,
    required this.count,
  });

  final String title;
  final String caption;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg + 2,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.brPill,
              ),
            ),
            const SizedBox(width: AppSpacing.ms),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.headingSm.copyWith(
                          color: p.textBody,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: AppRadius.brPill,
                        ),
                        child: Text(
                          '$count',
                          style: AppTypography.labelSm.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    caption,
                    style:
                        AppTypography.bodyXs.copyWith(color: p.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Items list
// ─────────────────────────────────────────────────────────────────────────────
class _ItemsList extends StatelessWidget {
  const _ItemsList({required this.items, required this.accent});

  final List<InventoryItem> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) => _InboxTile(
          item: items[index],
          accent: accent,
        ),
      ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({required this.item, required this.accent});

  final InventoryItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brXl,
        onTap: () {
          AppHaptics.tap();
          context.push(
            '${AppRoutes.productForm}?barcode=${item.barcode}',
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadius.brXl,
            border: Border.all(color: p.outlineSoft),
            boxShadow: AppElevation.card,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xl),
                      bottomLeft: Radius.circular(AppRadius.xl),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.ms),
                    child: Row(
                      children: <Widget>[
                        _Thumb(item: item, palette: p),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.name,
                                style: AppTypography.bodyMd.copyWith(
                                  color: p.textBody,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.brand != null &&
                                  item.brand!.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 1),
                                Text(
                                  item.brand!,
                                  style: AppTypography.bodyXs.copyWith(
                                    color: p.textMuted,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xs),
                              _StatusPill(item: item, accent: accent),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: p.textMuted.withValues(alpha: 0.55),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.item, required this.accent});
  final InventoryItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String text = _statusText(item);
    final IconData icon = _statusIcon(item);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: accent, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.labelSm.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(InventoryItem item) {
    if (item.status == ProductStatus.expired && item.expiryDate != null) {
      final int days = DateTime.now().difference(item.expiryDate!).inDays;
      if (days == 0) return 'Venció hoy';
      if (days == 1) return 'Venció hace 1 día';
      return 'Venció hace $days días';
    }
    if (item.status == ProductStatus.expiringSoon && item.expiryDate != null) {
      final int days = item.expiryDate!.difference(DateTime.now()).inDays;
      if (days <= 0) return 'Vence hoy';
      if (days == 1) return 'Vence mañana';
      return 'Vence en $days días · ${DateFormat('d MMM', 'es').format(item.expiryDate!)}';
    }
    if (item.isLowStock) {
      return 'Quedan ${item.quantity} ${item.quantity == 1 ? "unidad" : "unidades"}';
    }
    return '';
  }

  IconData _statusIcon(InventoryItem item) {
    if (item.status == ProductStatus.expired) {
      return Icons.error_outline_rounded;
    }
    if (item.status == ProductStatus.expiringSoon) {
      return Icons.timer_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item, required this.palette});
  final InventoryItem item;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    final String? url = item.imageUrl;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: palette.outlineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? Icon(Icons.inventory_2_outlined,
              color: palette.textMuted, size: 22)
          : (kIsWeb || url.startsWith('http'))
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: palette.textMuted,
                    size: 22,
                  ),
                )
              : Image.file(
                  File(url),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: palette.textMuted,
                    size: 22,
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.palette});
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F4EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF166534),
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sin notificaciones',
              style: AppTypography.headingMd.copyWith(color: palette.textBody),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tu despensa está en orden. Cuando un producto esté por vencer\no quede con poco stock, los avisos aparecerán aquí.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: palette.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
