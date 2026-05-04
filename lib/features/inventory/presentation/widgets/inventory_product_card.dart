import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/inventory_item.dart';
import '../models/pantry_card_item.dart';
import 'inventory_tokens.dart';

// ─────────────────────────────────────────────────────────────
// Status colour + label helpers
// ─────────────────────────────────────────────────────────────
extension _StatusStyle on ProductStatus {
  Color get color {
    switch (this) {
      case ProductStatus.expired:
        return const Color(0xFFD32F2F);
      case ProductStatus.expiringSoon:
        return const Color(0xFFF57C00);
      case ProductStatus.outOfStock:
        return const Color(0xFF9E9E9E);
      case ProductStatus.normal:
        return InventoryTokens.secondary;
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
        return 'Muy fresco';
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
}

// ─────────────────────────────────────────────────────────────
// Horizontal product card (image left, info right)
// ─────────────────────────────────────────────────────────────
class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({super.key, required this.item});

  final PantryCardItem item;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = item.status.color;
    final bool isDimmed =
        item.status == ProductStatus.outOfStock || item.status == ProductStatus.expired;

    return Opacity(
      opacity: isDimmed ? 0.72 : 1.0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: item.status == ProductStatus.normal
                ? InventoryTokens.outline.withValues(alpha: 0.18)
                : statusColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: statusColor.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            // ── Left: product image ──
            SizedBox(
              width: 110,
              child: _ProductImage(item: item, isDimmed: isDimmed),
            ),

            // ── Right: product info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Category + status badge row
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800,
                              color: InventoryTokens.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusBadge(status: item.status, statusColor: statusColor),
                      ],
                    ),

                    // Product name
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.8,
                        color: InventoryTokens.primary,
                      ),
                    ),

                    // Quantity + progress bar row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12,
                              color: InventoryTokens.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.quantity,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: InventoryTokens.textBody,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item.status == ProductStatus.outOfStock
                                  ? 'SIN STOCK'
                                  : item.status == ProductStatus.expired
                                      ? 'VENCIDO'
                                      : '${item.daysLeft} DÍAS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE9E9DD),
                            color: statusColor,
                          ),
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

// ─────────────────────────────────────────────────────────────
// Image sub-widget — handles local file, network URL, or placeholder
// ─────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.item, required this.isDimmed});

  final PantryCardItem item;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = item.status.color;

    Widget imageWidget;

    // Decide source: local file path vs network URL vs placeholder
    final String url = item.imageUrl;
    if (url.isNotEmpty && !url.startsWith('http')) {
      // Local file from image_picker
      final File file = File(url);
      imageWidget = Image.file(file, fit: BoxFit.cover, errorBuilder: _placeholder);
    } else if (url.isNotEmpty) {
      // Network URL
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

  Widget _placeholderWidget(Color color) => ColoredBox(
        color: color.withOpacity(0.07),
        child: Center(
          child: Icon(
            Icons.inventory_2_outlined,
            color: color.withOpacity(0.4),
            size: 30,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// Compact status badge
// ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.statusColor});

  final ProductStatus status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: statusColor.withOpacity(0.35)),
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
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
