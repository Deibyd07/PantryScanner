import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/i18n/recipe_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../shopping_list/domain/repositories/shopping_list_repository.dart';
import '../../../shopping_list/presentation/providers/shopping_list_providers.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_ingredient.dart';
import '../../domain/entities/recipe_match.dart';
import '../providers/recipes_providers.dart';
import '../widgets/recipe_visual.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final Recipe? recipe = ref.watch(recipeByIdProvider(recipeId));
    final AsyncValue<List<RecipeMatch>> async =
        ref.watch(recipeMatchesProvider);

    if (recipe == null) {
      return Scaffold(
        backgroundColor: p.bg,
        appBar: AppBar(title: const Text('')),
        body: Center(
          child: Text(
            t.recipeDetailNotFound,
            style: AppTypography.bodyMd.copyWith(color: p.textMuted),
          ),
        ),
      );
    }

    final RecipeMatch? match = async.whenOrNull(
      data: (List<RecipeMatch> all) =>
          all.firstWhere((RecipeMatch m) => m.recipe.id == recipeId),
    );

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: <Widget>[
          _DetailHero(recipe: recipe, match: match),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _MetaRow(recipe: recipe),
                  const SizedBox(height: AppSpacing.lg),
                  _IngredientsCard(recipe: recipe, match: match),
                  if (match != null && match.missingIngredients.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _AddMissingButton(recipe: recipe, match: match),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _StepsCard(recipe: recipe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.recipe, required this.match});

  final Recipe recipe;
  final RecipeMatch? match;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260 + topPad,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: RecipeVisual(
                meal: recipe.meal,
                imageUrl: recipe.imageUrl,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPad + AppSpacing.sm,
              left: AppSpacing.lg,
              child: _CircleIconBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  AppHaptics.tap();
                  context.pop();
                },
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (match != null && match!.canCookNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF166534),
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).recipeDetailCanCookNow,
                            style: AppTypography.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (match != null && match!.canCookNow)
                    const SizedBox(height: AppSpacing.sm),
                  Text(
                    recipe.title,
                    style: AppTypography.displaySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meta row
// ─────────────────────────────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetaTile(
            icon: Icons.schedule_rounded,
            value: '${recipe.minutes}',
            unit: 'min',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetaTile(
            icon: Icons.local_fire_department_outlined,
            value: recipe.difficulty.label(context),
            unit: t.recipeDetailDifficultyLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetaTile(
            icon: Icons.people_outline_rounded,
            value: '${recipe.servings}',
            unit: recipe.servings == 1
                ? t.recipeDetailServingsOne
                : t.recipeDetailServingsMany,
          ),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.value,
    required this.unit,
  });
  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: p.outlineSoft),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: p.brandPrimary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headingSm.copyWith(
              color: p.textBody,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            unit,
            style: AppTypography.labelSm.copyWith(
              color: p.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ingredients
// ─────────────────────────────────────────────────────────────────────────────
class _IngredientsCard extends StatelessWidget {
  const _IngredientsCard({required this.recipe, required this.match});
  final Recipe recipe;
  final RecipeMatch? match;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    return _SectionCard(
      title: t.recipeIngredientsTitle,
      caption: match == null
          ? t.recipeIngredientsCountTotal(recipe.ingredients.length)
          : t.recipeIngredientsCountDetail(
              match!.matchedIngredients.length,
              match!.missingIngredients.length,
            ),
      icon: Icons.shopping_basket_outlined,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < recipe.ingredients.length; i++) ...<Widget>[
            if (i > 0) Divider(color: p.outlineSoft, height: 1),
            _IngredientRow(
              ingredient: recipe.ingredients[i],
              status: _statusFor(recipe.ingredients[i]),
            ),
          ],
        ],
      ),
    );
  }

  _IngredientStatus _statusFor(RecipeIngredient ing) {
    if (match == null) return _IngredientStatus.unknown;
    if (match!.expiringIngredients.contains(ing)) {
      return _IngredientStatus.expiring;
    }
    if (match!.matchedIngredients.contains(ing)) {
      return _IngredientStatus.inPantry;
    }
    return ing.isOptional
        ? _IngredientStatus.optional
        : _IngredientStatus.missing;
  }
}

enum _IngredientStatus { inPantry, expiring, missing, optional, unknown }

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.status});

  final RecipeIngredient ingredient;
  final _IngredientStatus status;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    final _StatusSpec spec = _specFor(context, status, p);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: spec.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(spec.icon, size: 16, color: spec.iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ingredient.name,
                  style: AppTypography.bodyMd.copyWith(
                    color: p.textBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (spec.subtitle != null)
                  Text(
                    spec.subtitle!,
                    style: AppTypography.labelSm.copyWith(
                      color: spec.iconColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            ingredient.displayQuantity,
            style: AppTypography.bodySm.copyWith(
              color: p.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusSpec _specFor(BuildContext context, _IngredientStatus s, PaletteSpec p) {
    final AppLocalizations t = AppLocalizations.of(context);
    switch (s) {
      case _IngredientStatus.inPantry:
        return _StatusSpec(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF166534),
          iconBg: const Color(0xFFE6F4EA),
          subtitle: t.recipeIngredientInPantry,
        );
      case _IngredientStatus.expiring:
        return _StatusSpec(
          icon: Icons.timer_outlined,
          iconColor: AppColors.warningStrong,
          iconBg: AppColors.warningStrong.withValues(alpha: 0.14),
          subtitle: t.recipeIngredientExpiring,
        );
      case _IngredientStatus.missing:
        return _StatusSpec(
          icon: Icons.shopping_cart_outlined,
          iconColor: p.brandPrimary,
          iconBg: p.brandPrimary.withValues(alpha: 0.12),
          subtitle: t.recipeIngredientMissing,
        );
      case _IngredientStatus.optional:
        return _StatusSpec(
          icon: Icons.add_rounded,
          iconColor: p.textMuted,
          iconBg: p.surfaceMuted,
          subtitle: t.recipeIngredientOptional,
        );
      case _IngredientStatus.unknown:
        return _StatusSpec(
          icon: Icons.circle_outlined,
          iconColor: p.textMuted,
          iconBg: p.surfaceMuted,
          subtitle: null,
        );
    }
  }
}

class _StatusSpec {
  const _StatusSpec({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? subtitle;
}

// ─────────────────────────────────────────────────────────────────────────────
// Add missing ingredients to shopping list
// ─────────────────────────────────────────────────────────────────────────────
class _AddMissingButton extends ConsumerWidget {
  const _AddMissingButton({required this.recipe, required this.match});

  final Recipe recipe;
  final RecipeMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations t = AppLocalizations.of(context);
    final int n = match.missingIngredients.length;
    final String label =
        n == 1 ? t.recipeAddMissingOne : t.recipeAddMissingMany(n);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () async {
          AppHaptics.confirm();
          final List<ShoppingListItemDraft> drafts = match.missingIngredients
              .map((RecipeIngredient i) => ShoppingListItemDraft(
                    name: i.name,
                    quantity: i.displayQuantity.isEmpty
                        ? null
                        : i.displayQuantity,
                    sourceRecipeId: recipe.id,
                    sourceTitle: recipe.title,
                  ))
              .toList();
          final int added = await ref
              .read(shoppingListRepositoryProvider)
              .addItems(drafts: drafts);
          if (!context.mounted) return;
          _showAddedSnack(context, added: added, total: drafts.length);
        },
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.palette.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.brLg,
          ),
          textStyle: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showAddedSnack(
    BuildContext context, {
    required int added,
    required int total,
  }) {
    final AppLocalizations t = AppLocalizations.of(context);
    final int skipped = total - added;
    final String msg = added == 0
        ? t.recipeAddedAllExisted
        : skipped == 0
            ? added == 1
                ? t.recipeAddedOne
                : t.recipeAddedMany(added)
            : t.recipeAddedMixed(added, skipped);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: added == 0
              ? const Color(0xFFB45309)
              : const Color(0xFF166534),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                added == 0
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: added == 0
              ? null
              : SnackBarAction(
                  label: t.recipeViewList,
                  textColor: Colors.white,
                  onPressed: () => context.push(AppRoutes.shoppingList),
                ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Steps
// ─────────────────────────────────────────────────────────────────────────────
class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    return _SectionCard(
      title: t.recipeStepsTitle,
      caption: t.recipeStepsCount(recipe.steps.length),
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < recipe.steps.length; i++)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.labelSm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        recipe.steps[i],
                        style: AppTypography.bodyMd.copyWith(
                          color: p.textBody,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section card
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.caption,
    required this.icon,
    required this.child,
  });

  final String title;
  final String caption;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(icon, color: p.brandPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.headingSm.copyWith(
                        color: p.textBody,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      caption,
                      style: AppTypography.labelSm.copyWith(
                        color: p.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
