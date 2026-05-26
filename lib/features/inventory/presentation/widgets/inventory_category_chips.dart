import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

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
    final PaletteSpec p = context.palette;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              AppHaptics.select();
              onSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: selected ? p.brandPrimary : p.surface,
                borderRadius: AppRadius.brPill,
                border: Border.all(
                  color: selected ? p.brandPrimary : p.outline,
                ),
              ),
              child: Text(
                categories[index],
                style: AppTypography.labelSm.copyWith(
                  color: selected ? p.onBrand : p.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
