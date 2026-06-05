import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/sources/local_recipes_catalog.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final recipe in const LocalRecipesCatalog().getAll()) {
      final String? url = recipe.imageUrl;
      if (url != null && url.isNotEmpty) {
        precacheImage(
          ResizeImage(CachedNetworkImageProvider(url), width: 800),
          context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final AsyncValue<List<RecipeMatch>> async =
        ref.watch(recipeMatchesProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            t.recipesLoadError,
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
                t: t,
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
                    t: t,
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
                  child: _EmptyState(filter: _filter, palette: p, t: t),
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
    required this.t,
  });

  final int total;
  final int cookable;
  final int withExpiring;
  final AppLocalizations t;

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
                  tooltip: t.recipesViewPantry,
                  onTap: () {
                    AppHaptics.tap();
                    context.go(AppRoutes.inventory);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.recipesHeroTitle,
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? t.recipesHeroEmpty
                  : cookable == 0
                      ? t.recipesHeroNoneCookable
                      : t.recipesHeroCookable(cookable),
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    label: t.recipesStatCatalog,
                    count: total,
                    icon: Icons.menu_book_rounded,
                    accent: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: t.recipesStatCookable,
                    count: cookable,
                    icon: Icons.local_dining_rounded,
                    accent: const Color(0xFFC8E6C9),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: t.recipesStatExpiring,
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
  const _FilterChips({
    required this.selected,
    required this.onSelected,
    required this.t,
  });

  final _RecipeFilter selected;
  final ValueChanged<_RecipeFilter> onSelected;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _Chip(
            label: t.recipesFilterAll,
            selected: selected == _RecipeFilter.todas,
            onTap: () => onSelected(_RecipeFilter.todas),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: t.recipesFilterCookable,
            selected: selected == _RecipeFilter.puedoCocinar,
            onTap: () => onSelected(_RecipeFilter.puedoCocinar),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: t.recipesFilterExpiring,
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
  const _EmptyState({
    required this.filter,
    required this.palette,
    required this.t,
  });

  final _RecipeFilter filter;
  final PaletteSpec palette;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String body;
    switch (filter) {
      case _RecipeFilter.todas:
        title = t.recipesEmptyTitleAll;
        body = t.recipesEmptyBodyAll;
        break;
      case _RecipeFilter.puedoCocinar:
        title = t.recipesEmptyTitleCookable;
        body = t.recipesEmptyBodyCookable;
        break;
      case _RecipeFilter.porVencer:
        title = t.recipesEmptyTitleExpiring;
        body = t.recipesEmptyBodyExpiring;
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
