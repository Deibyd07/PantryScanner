import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pantry_card_item.dart';
import 'inventory_tokens.dart';

class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({super.key, required this.item});

  final PantryCardItem item;

  @override
  Widget build(BuildContext context) {
    final Color tagColor = item.highlight ? InventoryTokens.tertiary : InventoryTokens.secondary;
    final String tagText = item.highlight ? 'Vence pronto' : 'Muy fresco';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InventoryTokens.outline.withValues(alpha: 0.2)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14154212),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFE9E9DD),
                          child: Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: InventoryTokens.textMuted,
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          tagText.toUpperCase(),
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
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE9E9DD),
                    color: tagColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.daysLeft} dias'.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: tagColor,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
