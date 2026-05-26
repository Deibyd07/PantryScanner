import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/inventory_item.dart';
import '../models/pantry_card_item.dart';

extension _StatusStyle on ProductStatus {
  Color get color {
    switch (this) {
      case ProductStatus.expired:
        return AppColors.dangerStrong;
      case ProductStatus.expiringSoon:
        return AppColors.warningStrong;
      case ProductStatus.outOfStock:
        return AppColors.neutralStrong;
      case ProductStatus.normal:
        return AppColors.successStrong;
    }
  }

  Color get colorLight {
    switch (this) {
      case ProductStatus.expired:
        return AppColors.dangerSoft;
      case ProductStatus.expiringSoon:
        return AppColors.warningSoft;
      case ProductStatus.outOfStock:
        return AppColors.neutralSoft;
      case ProductStatus.normal:
        return AppColors.successSoft;
    }
  }

  String get label {
    switch (this) {
      case ProductStatus.expired:
        return 'Vencido';
      case ProductStatus.expiringSoon:
        return 'Vence pronto';
      case ProductStatus.outOfStock:
        return 'Agotado';
      case ProductStatus.normal:
        return 'Fresco';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductStatus.expired:
        return Icons.cancel_outlined;
      case ProductStatus.expiringSoon:
        return Icons.timer_outlined;
      case ProductStatus.outOfStock:
        return Icons.remove_shopping_cart_outlined;
      case ProductStatus.normal:
        return Icons.check_circle_outline;
    }
  }

  Color get bgColor {
    switch (this) {
      case ProductStatus.expired:
        return AppColors.dangerBg;
      case ProductStatus.expiringSoon:
        return AppColors.warningBg;
      case ProductStatus.outOfStock:
        return AppColors.neutralBg;
      case ProductStatus.normal:
        return AppColors.successBg;
    }
  }
}

class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
  });

  final PantryCardItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final Color statusColor = item.status.color;
    final bool isDimmed =
        item.status == ProductStatus.outOfStock || item.status == ProductStatus.expired;

    return Opacity(
      opacity: isDimmed ? 0.7 : 1.0,
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: AppRadius.brXl,
          boxShadow: AppElevation.cardStatus(statusColor, dimmed: isDimmed),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Left accent strip ──────────────────────────────────────────
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[item.status.colorLight, statusColor],
                ),
              ),
            ),

            // ── Product image ──────────────────────────────────────────────
            SizedBox(
              width: 96,
              child: _ProductImage(item: item, isDimmed: isDimmed),
            ),

            // ── Info section ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.ms,
                  AppSpacing.ms,
                  AppSpacing.ms + 2,
                  AppSpacing.ms,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Category + badge
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: p.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        _StatusBadge(status: item.status, statusColor: statusColor),
                      ],
                    ),

                    // Product name
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingXs.copyWith(color: p.textBody),
                    ),

                    // Quantity stepper + days left + progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _QuantityStepper(
                              quantity: item.rawQuantity,
                              onDecrement: onDecrement,
                              onIncrement: onIncrement,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs + 2,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Text(
                                item.status == ProductStatus.outOfStock
                                    ? 'SIN STOCK'
                                    : item.status == ProductStatus.expired
                                        ? 'VENCIDO'
                                        : '${item.daysLeft}d restantes',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm - 2),
                        _GradientBar(
                          progress: item.progress,
                          color: statusColor,
                          colorLight: item.status.colorLight,
                          trackColor: p.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GradientBar extends StatelessWidget {
  const _GradientBar({
    required this.progress,
    required this.color,
    required this.colorLight,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color colorLight;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double fillWidth = (constraints.maxWidth * progress).clamp(0.0, constraints.maxWidth);
        return ClipRRect(
          borderRadius: AppRadius.brPill,
          child: Stack(
            children: <Widget>[
              Container(height: 4, color: trackColor),
              Container(
                height: 4,
                width: fillWidth,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.brPill,
                  gradient: LinearGradient(colors: <Color>[colorLight, color]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.item, required this.isDimmed});

  final PantryCardItem item;
  final bool isDimmed;

  IconData get _categoryIcon {
    switch (item.category.toLowerCase()) {
      case 'lácteos':
        return Icons.water_drop_outlined;
      case 'carnes':
        return Icons.restaurant_outlined;
      case 'frutas y verduras':
        return Icons.eco_outlined;
      case 'enlatados':
        return Icons.inventory_2_outlined;
      case 'bebidas':
        return Icons.local_bar_outlined;
      case 'snacks':
        return Icons.fastfood_outlined;
      case 'cereales':
        return Icons.grain_outlined;
      case 'condimentos':
        return Icons.soup_kitchen_outlined;
      default:
        return Icons.kitchen_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = item.status.color;

    Widget imageWidget;
    final String url = item.imageUrl;

    if (url.isNotEmpty && !url.startsWith('http')) {
      if (kIsWeb) {
        imageWidget = Image.network(url, fit: BoxFit.cover, errorBuilder: _placeholder);
      } else {
        imageWidget = Image.file(File(url), fit: BoxFit.cover, errorBuilder: _placeholder);
      }
    } else if (url.isNotEmpty) {
      imageWidget = Image.network(url, fit: BoxFit.cover, errorBuilder: _placeholder);
    } else {
      imageWidget = _placeholderWidget(statusColor);
    }

    return ColorFiltered(
      colorFilter: isDimmed
          ? const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ])
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: SizedBox.expand(child: imageWidget),
    );
  }

  Widget _placeholder(BuildContext ctx, Object err, StackTrace? st) =>
      _placeholderWidget(item.status.color);

  Widget _placeholderWidget(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _categoryIcon,
          color: color.withValues(alpha: 0.5),
          size: 30,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    this.onDecrement,
    this.onIncrement,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: p.brandPrimary.withValues(alpha: 0.08),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepBtn(icon: Icons.remove_rounded, color: p.brandPrimary, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2),
            child: Text(
              '$quantity',
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w800,
                color: p.brandPrimary,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add_rounded, color: p.brandPrimary, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brPill,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            icon,
            size: 14,
            color: onTap == null ? color.withValues(alpha: 0.35) : color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.statusColor});

  final ProductStatus status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(status.icon, size: 9, color: statusColor),
          const SizedBox(width: 3),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
