import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../providers/shopping_list_providers.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final TextEditingController _quickAddCtrl = TextEditingController();

  @override
  void dispose() {
    _quickAddCtrl.dispose();
    super.dispose();
  }

  Future<void> _addQuick() async {
    final String text = _quickAddCtrl.text.trim();
    if (text.isEmpty) return;
    AppHaptics.confirm();
    await ref.read(shoppingListRepositoryProvider).addItem(name: text);
    _quickAddCtrl.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AsyncValue<List<ShoppingListItem>> async =
        ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            'No se pudo cargar la lista',
            style: AppTypography.bodyMd.copyWith(color: p.textMuted),
          ),
        ),
        data: (List<ShoppingListItem> items) {
          final List<ShoppingListItem> pending = items
              .where((ShoppingListItem i) => !i.isChecked)
              .toList();
          final List<ShoppingListItem> done = items
              .where((ShoppingListItem i) => i.isChecked)
              .toList();

          final Map<String?, List<ShoppingListItem>> pendingGrouped =
              <String?, List<ShoppingListItem>>{};
          for (final ShoppingListItem item in pending) {
            pendingGrouped
                .putIfAbsent(item.sourceTitle, () => <ShoppingListItem>[])
                .add(item);
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              _Hero(
                total: items.length,
                pending: pending.length,
                done: done.length,
                onClearDone: done.isEmpty
                    ? null
                    : () async {
                        AppHaptics.warning();
                        final bool? ok = await _confirmClear(context);
                        if (ok == true) {
                          await ref
                              .read(shoppingListRepositoryProvider)
                              .clearCompleted();
                        }
                      },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _QuickAdd(
                    controller: _quickAddCtrl,
                    onSubmit: _addQuick,
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Empty(palette: p),
                )
              else ...<Widget>[
                if (pending.isNotEmpty)
                  ..._buildPendingSlivers(pendingGrouped, p),
                if (done.isNotEmpty) ...<Widget>[
                  _SectionHeader(
                    title: 'Ya tienes',
                    caption: 'Marcados como conseguidos',
                    color: AppColors.successStrong,
                    count: done.length,
                  ),
                  _ItemsList(items: done, palette: p),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPendingSlivers(
    Map<String?, List<ShoppingListItem>> grouped,
    PaletteSpec p,
  ) {
    final List<MapEntry<String?, List<ShoppingListItem>>> entries =
        grouped.entries.toList()
          ..sort((a, b) {
            // null (manual) primero, luego alfabético por título de receta
            if (a.key == null && b.key != null) return -1;
            if (a.key != null && b.key == null) return 1;
            return (a.key ?? '').compareTo(b.key ?? '');
          });

    return <Widget>[
      for (final MapEntry<String?, List<ShoppingListItem>> e in entries) ...<Widget>[
        _SectionHeader(
          title: e.key ?? 'Por comprar',
          caption: e.key == null
              ? 'Agregados manualmente'
              : 'Faltan para preparar esta receta',
          color: e.key == null ? p.brandPrimary : AppColors.warningStrong,
          count: e.value.length,
        ),
        _ItemsList(items: e.value, palette: p),
      ],
    ];
  }

  Future<bool?> _confirmClear(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        title: const Text('Quitar conseguidos'),
        content: const Text(
          '¿Quieres borrar todos los ítems que ya marcaste como conseguidos?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerStrong),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({
    required this.total,
    required this.pending,
    required this.done,
    required this.onClearDone,
  });

  final int total;
  final int pending;
  final int done;
  final VoidCallback? onClearDone;

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
                _CircleBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    Navigator.of(context).pop();
                  },
                ),
                const Spacer(),
                if (onClearDone != null)
                  _CircleBtn(
                    icon: Icons.cleaning_services_rounded,
                    tooltip: 'Borrar conseguidos',
                    onTap: onClearDone!,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Lista de compras',
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? 'Aún no has añadido nada'
                  : pending == 0
                      ? '¡Todo conseguido!'
                      : pending == 1
                          ? '1 ítem por comprar'
                          : '$pending ítems por comprar',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    label: 'Total',
                    count: total,
                    icon: Icons.shopping_basket_outlined,
                    accent: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Pendientes',
                    count: pending,
                    icon: Icons.radio_button_unchecked_rounded,
                    accent: const Color(0xFFFFE0B2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: 'Conseguidos',
                    count: done,
                    icon: Icons.check_circle_outline_rounded,
                    accent: const Color(0xFFC8E6C9),
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

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.tooltip});
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
// Quick add
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: p.outline),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: AppSpacing.md),
          Icon(Icons.add_shopping_cart_rounded,
              size: 20, color: p.brandPrimary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: 'Añadir ítem (ej. Leche, Pan...)',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: p.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: AppTypography.bodyMd.copyWith(color: p.textBody),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.brMd,
              onTap: onSubmit,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.caption,
    required this.color,
    required this.count,
  });

  final String title;
  final String caption;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.brPill,
              ),
            ),
            const SizedBox(width: AppSpacing.ms),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.headingSm.copyWith(
                            color: p.textBody,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: AppRadius.brPill,
                        ),
                        child: Text(
                          '$count',
                          style: AppTypography.labelSm.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    caption,
                    style: AppTypography.bodyXs.copyWith(color: p.textMuted),
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

// ─────────────────────────────────────────────────────────────────────────────
// Items list
// ─────────────────────────────────────────────────────────────────────────────
class _ItemsList extends ConsumerWidget {
  const _ItemsList({required this.items, required this.palette});

  final List<ShoppingListItem> items;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final ShoppingListItem item = items[index];
          return Dismissible(
            key: ValueKey<int>(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.dangerStrong,
                borderRadius: AppRadius.brXl,
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 24),
            ),
            onDismissed: (_) {
              AppHaptics.error();
              ref.read(shoppingListRepositoryProvider).deleteItem(item.id);
            },
            child: _ItemTile(item: item),
          );
        },
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item});
  final ShoppingListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final bool checked = item.isChecked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brXl,
        onTap: () {
          AppHaptics.tap();
          ref
              .read(shoppingListRepositoryProvider)
              .toggleChecked(item.id, isChecked: !checked);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadius.brXl,
            border: Border.all(color: p.outlineSoft),
            boxShadow: AppElevation.card,
          ),
          child: Row(
            children: <Widget>[
              _CheckBubble(checked: checked),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      style: AppTypography.bodyMd.copyWith(
                        color: checked
                            ? p.textMuted
                            : p.textBody,
                        fontWeight: FontWeight.w700,
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: p.textMuted,
                      ),
                    ),
                    if (item.quantity != null && item.quantity!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.quantity!,
                          style: AppTypography.bodyXs.copyWith(
                            color: p.textMuted,
                          ),
                        ),
                      ),
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

class _CheckBubble extends StatelessWidget {
  const _CheckBubble({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: checked ? AppColors.brandGradient : null,
        color: checked ? null : p.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? Colors.transparent : p.outline,
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _Empty extends StatelessWidget {
  const _Empty({required this.palette});
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
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
                Icons.shopping_basket_outlined,
                color: palette.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tu lista está vacía',
              style: AppTypography.headingMd.copyWith(color: palette.textBody),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Añade ítems con el campo de arriba o desde una receta usando '
              '"Añadir faltantes a la lista".',
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
