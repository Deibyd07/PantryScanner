import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/sort_preference.dart';
import '../providers/sort_providers.dart';

class SortBottomSheet extends ConsumerStatefulWidget {
  const SortBottomSheet({super.key});

  @override
  ConsumerState<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends ConsumerState<SortBottomSheet> {
  late SortPreference _local;

  @override
  void initState() {
    super.initState();
    _local = ref.read(sortPreferenceProvider);
  }

  static const List<({SortCriteria criteria, IconData icon})> _options = <({SortCriteria criteria, IconData icon})>[
    (criteria: SortCriteria.expiryDate, icon: Icons.event_outlined),
    (criteria: SortCriteria.name, icon: Icons.sort_by_alpha_rounded),
    (criteria: SortCriteria.quantity, icon: Icons.inventory_2_outlined),
    (criteria: SortCriteria.category, icon: Icons.category_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.outline,
                  borderRadius: AppRadius.brPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ordenar por',
              style: AppTypography.headingSm.copyWith(color: p.textBody),
            ),
            const SizedBox(height: AppSpacing.ms),

            // Criteria options
            ..._options.map(
              (({SortCriteria criteria, IconData icon}) opt) {
                final bool selected = _local.criteria == opt.criteria;
                return GestureDetector(
                  onTap: () {
                    AppHaptics.select();
                    setState(() {
                      _local = _local.copyWith(criteria: opt.criteria);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.ms,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? p.brandPrimary.withValues(alpha: 0.08)
                          : p.surface,
                      borderRadius: AppRadius.brLg,
                      border: Border.all(
                        color: selected ? p.brandPrimary : p.outline,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          opt.icon,
                          size: 20,
                          color: selected ? p.brandPrimary : p.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.ms),
                        Expanded(
                          child: Text(
                            opt.criteria.label,
                            style: AppTypography.bodyMd.copyWith(
                              color: selected ? p.brandPrimary : p.textBody,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: p.brandPrimary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // Direction toggle
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: p.outline.withValues(alpha: 0.4),
                borderRadius: AppRadius.brLg,
              ),
              child: Row(
                children: <Widget>[
                  _DirectionBtn(
                    label: 'Ascendente',
                    icon: Icons.arrow_upward_rounded,
                    selected: _local.ascending,
                    palette: p,
                    onTap: () {
                      AppHaptics.select();
                      setState(() => _local = _local.copyWith(ascending: true));
                    },
                  ),
                  _DirectionBtn(
                    label: 'Descendente',
                    icon: Icons.arrow_downward_rounded,
                    selected: !_local.ascending,
                    palette: p,
                    onTap: () {
                      AppHaptics.select();
                      setState(() => _local = _local.copyWith(ascending: false));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  AppHaptics.confirm();
                  ref.read(sortPreferenceProvider.notifier).update(_local);
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: p.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brLg,
                  ),
                ),
                child: const Text('Aplicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionBtn extends StatelessWidget {
  const _DirectionBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final PaletteSpec palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: selected ? palette.surface : Colors.transparent,
            borderRadius: AppRadius.brMd,
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected ? palette.brandPrimary : palette.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: selected ? palette.brandPrimary : palette.textMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
