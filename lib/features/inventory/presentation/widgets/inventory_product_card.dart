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
        return const Color(0xFFD32F2F); // Red
      case ProductStatus.expiringSoon:
        return const Color(0xFFF57C00); // Orange
      case ProductStatus.outOfStock:
        return const Color(0xFF9E9E9E); // Grey
      case ProductStatus.normal:
        return InventoryTokens.secondary; // Green
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
// Card widget
// ─────────────────────────────────────────────────────────────
class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({super.key, required this.item});

  final PantryCardItem item;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = item.status.color;
    final bool isOutOfStock = item.status == ProductStatus.outOfStock;
    final bool isExpired = item.status == ProductStatus.expired;
    final double cardOpacity = (isOutOfStock || isExpired) ? 0.65 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: item.status == ProductStatus.normal
                ? InventoryTokens.outline.withValues(alpha: 0.2)
                : statusColor.withValues(alpha: 0.4),
            width: item.status == ProductStatus.normal ? 1 : 1.5,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Image with status badge ──
            Expanded(
              child: Stack(
                children: <Widget>[
                  // Product image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColorFiltered(
                        colorFilter: (isOutOfStock || isExpired)
                            ? const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ])
                            : const ColorFilter.mode(
                                Colors.transparent, BlendMode.multiply),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext ctx, Object err, StackTrace? st) {
                            return ColoredBox(
                              color: statusColor.withValues(alpha: 0.08),
                              child: Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: statusColor.withValues(alpha: 0.5),
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(item.status.icon, color: Colors.white, size: 10),
                          const SizedBox(width: 5),
                          Text(
                            item.status.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Category label
            Text(
              item.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: InventoryTokens.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            // Name + Quantity row
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.epilogue(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: -1.5,
                      color: InventoryTokens.primary,
                    ),
                  ),
                ),
                Text(
                  item.quantity,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: InventoryTokens.textBody,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar + days label
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE9E9DD),
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    letterSpacing: 0.8,
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
