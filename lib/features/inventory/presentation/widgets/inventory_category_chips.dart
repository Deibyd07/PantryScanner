import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

class InventoryCategoryChips extends StatelessWidget {
  const InventoryCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.counts,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  /// Optional product count per chip index.
  final List<int>? counts;

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    categories[index],
                    style: AppTypography.labelSm.copyWith(
                      color: selected ? p.onBrand : p.textMuted,
                    ),
                  ),
                  if (counts != null && index < counts!.length) ...<Widget>[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: selected
                            ? p.onBrand.withValues(alpha: 0.25)
                            : p.brandPrimary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(
                        '${counts![index]}',
                        style: AppTypography.caption.copyWith(
                          color: selected ? p.onBrand : p.brandPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
