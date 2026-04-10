import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'inventory_tokens.dart';

class InventoryCategoryChips extends StatelessWidget {
  const InventoryCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = selectedIndex == index;
          return ChoiceChip(
            label: Text(
              categories[index],
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            selected: selected,
            onSelected: (_) => onSelected(index),
            selectedColor: InventoryTokens.primary,
            backgroundColor: const Color(0xFFEFEEE3),
            side: BorderSide(
              color: selected
                  ? Colors.transparent
                  : InventoryTokens.outline.withValues(alpha: 0.45),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : InventoryTokens.textBody,
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}
