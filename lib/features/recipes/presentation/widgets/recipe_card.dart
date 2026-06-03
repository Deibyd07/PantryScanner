import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_match.dart';
import 'recipe_visual.dart';

/// Tarjeta de receta para la lista principal.
///
/// Muestra la imagen visual (o gradiente con icono según el tipo de comida),
/// título, tiempo, dificultad, % de cobertura, y badges contextuales:
/// - "Aprovecha por vencer" cuando la receta usa productos de la despensa
///   que están por vencer o vencidos.
/// - "Te faltan N" cuando la receta no es cocinable completa.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.match, required this.onTap});

  final RecipeMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final Recipe r = match.recipe;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brXl,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadius.brXl,
            border: Border.all(color: p.outlineSoft),
            boxShadow: AppElevation.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 120,
                child: RecipeVisual(
                  meal: r.meal,
                  imageUrl: r.imageUrl,
                  trailing: _CoveragePill(match: match),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      r.title,
                      style: AppTypography.headingSm.copyWith(
                        color: p.textBody,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.description,
                      style: AppTypography.bodyXs.copyWith(
                        color: p.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          label: '${r.minutes} min',
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _MetaChip(
                          icon: Icons.local_fire_department_outlined,
                          label: r.difficulty.label,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _MetaChip(
                          icon: Icons.restaurant_outlined,
                          label: r.meal.label,
                        ),
                      ],
                    ),
                    if (match.usesExpiring || !match.canCookNow) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 4,
                        children: <Widget>[
                          if (match.usesExpiring)
                            _StatusBadge(
                              icon: Icons.timer_outlined,
                              label: match.expiringIngredients.length == 1
                                  ? 'Aprovecha 1 producto por vencer'
                                  : 'Aprovecha ${match.expiringIngredients.length} productos por vencer',
                              color: AppColors.warningStrong,
                            ),
                          if (!match.canCookNow)
                            _StatusBadge(
                              icon: Icons.shopping_cart_outlined,
                              label: match.missingIngredients.length == 1
                                  ? 'Te falta 1 ingrediente'
                                  : 'Te faltan ${match.missingIngredients.length} ingredientes',
                              color: p.textMuted,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoveragePill extends StatelessWidget {
  const _CoveragePill({required this.match});
  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final bool ready = match.canCookNow;
    final Color bg = ready
        ? const Color(0xFF166534)
        : Colors.black.withValues(alpha: 0.55);
    final String label = ready ? 'Listo' : '${match.coveragePercent}%';
    final IconData icon =
        ready ? Icons.check_circle_rounded : Icons.pie_chart_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: p.outlineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: p.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: p.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
