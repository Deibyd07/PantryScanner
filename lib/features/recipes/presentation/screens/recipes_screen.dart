import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../domain/entities/recipe_match.dart';
import '../providers/recipes_providers.dart';
import '../widgets/recipe_card.dart';

enum _RecipeFilter { todas, puedoCocinar, porVencer }

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  _RecipeFilter _filter = _RecipeFilter.todas;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AsyncValue<List<RecipeMatch>> async =
        ref.watch(recipeMatchesProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            'No se pudieron cargar las recetas',
            style: AppTypography.bodyMd.copyWith(color: p.textMuted),
          ),
        ),
        data: (List<RecipeMatch> matches) {
          final int cookable =
              matches.where((RecipeMatch m) => m.canCookNow).length;
          final int withExpiring =
              matches.where((RecipeMatch m) => m.usesExpiring).length;

          final List<RecipeMatch> filtered = _applyFilter(matches);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              _RecipesHero(
                total: matches.length,
                cookable: cookable,
                withExpiring: withExpiring,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _FilterChips(
                    selected: _filter,
                    onSelected: (_RecipeFilter f) {
                      AppHaptics.select();
                      setState(() => _filter = f);
                    },
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(filter: _filter, palette: p),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final RecipeMatch m = filtered[index];
                      return RecipeCard(
                        match: m,
                        onTap: () {
                          AppHaptics.tap();
                          context.push('${AppRoutes.recipes}/${m.recipe.id}');
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<RecipeMatch> _applyFilter(List<RecipeMatch> all) {
    switch (_filter) {
      case _RecipeFilter.todas:
        return all;
      case _RecipeFilter.puedoCocinar:
        return all.where((RecipeMatch m) => m.canCookNow).toList();
      case _RecipeFilter.porVencer:
        return all.where((RecipeMatch m) => m.usesExpiring).toList();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _RecipesHero extends StatelessWidget {
  const _RecipesHero({
    required this.total,
    required this.cookable,
    required this.withExpiring,
  });

  final int total;
  final int cookable;
  final int withExpiring;

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
                _CircleIconBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    context.pop();
                  },
                ),
                const Spacer(),
                _CircleIconBtn(
                  icon: Icons.kitchen_rounded,
                  tooltip: 'Ver despensa',
                  onTap: () {
                    AppHaptics.tap();
                    context.go(AppRoutes.inventory);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cocina con lo que tienes',
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? 'Aún no hay recetas en el catálogo'
                  : cookable == 0
                      ? 'Te faltan algunos ingredientes para cocinar completo'
                      : cookable == 1
                          ? '1 receta lista para cocinar ahora'
                          : '$cookable recetas listas para cocinar ahora',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    label: 'En catálogo',
                    count: total,
                    icon: Icons.menu_book_rounded,
                    accent: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Puedes cocinar',
                    count: cookable,
                    icon: Icons.local_dining_rounded,
                    accent: const Color(0xFFC8E6C9),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Por vencer',
                    count: withExpiring,
                    icon: Icons.timer_outlined,
                    accent: const Color(0xFFFFE0B2),
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

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({
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
// Filter chips
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final _RecipeFilter selected;
  final ValueChanged<_RecipeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _Chip(
            label: 'Todas',
            selected: selected == _RecipeFilter.todas,
            onTap: () => onSelected(_RecipeFilter.todas),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: 'Puedo cocinar',
            selected: selected == _RecipeFilter.puedoCocinar,
            onTap: () => onSelected(_RecipeFilter.puedoCocinar),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: 'Aprovecha por vencer',
            selected: selected == _RecipeFilter.porVencer,
            onTap: () => onSelected(_RecipeFilter.porVencer),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return GestureDetector(
      onTap: onTap,
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
          label,
          style: AppTypography.labelSm.copyWith(
            color: selected ? p.onBrand : p.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.palette});

  final _RecipeFilter filter;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String body;
    switch (filter) {
      case _RecipeFilter.todas:
        title = 'Sin recetas';
        body = 'Pronto añadiremos más recetas al catálogo.';
        break;
      case _RecipeFilter.puedoCocinar:
        title = 'Te faltan ingredientes';
        body = 'Aún no tienes en despensa todos los ingredientes para cocinar una receta completa. Mira el resto y compra lo que te falte.';
        break;
      case _RecipeFilter.porVencer:
        title = 'Nada por vencer';
        body = 'Ninguna receta del catálogo usa productos que estés por perder. ¡Buena gestión!';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                color: palette.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headingMd.copyWith(color: palette.textBody),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
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
