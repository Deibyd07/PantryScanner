import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/analytics/app_analytics.dart';
import '../../../../core/design/design_system.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/utils/quick_add_parser.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
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
    final ParsedAdd parsed = parseQuickAdd(text);
    AppHaptics.confirm();
    await ref.read(shoppingListRepositoryProvider).addItem(
          name: parsed.name,
          quantity: parsed.quantity,
        );
    AppAnalytics.logShoppingItemAdded().ignore();
    _quickAddCtrl.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _showEditSheet(BuildContext context, ShoppingListItem item) async {
    final _EditResult? result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (BuildContext ctx) => _EditItemSheet(item: item),
    );

    if (result == null || !mounted) return;
    if (result.delete) {
      await _deleteWithUndo(item);
      return;
    }
    AppHaptics.confirm();
    await ref.read(shoppingListRepositoryProvider).updateItem(
          item.id,
          name: result.name,
          quantity: result.quantity,
        );
  }

  Future<void> _deleteWithUndo(ShoppingListItem item) async {
    AppHaptics.warning();
    await ref.read(shoppingListRepositoryProvider).deleteItem(item.id);
    if (!mounted) return;
    final AppLocalizations t = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller =
        messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(t.cartDeletedSnack(item.name)),
        action: SnackBarAction(
          label: t.commonUndo,
          onPressed: () async {
            AppHaptics.tap();
            await ref
                .read(shoppingListRepositoryProvider)
                .restoreItem(item);
          },
        ),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 3), () {
      try {
        controller.close();
      } catch (_) {/* ya cerrado */}
    });
  }

  Future<void> _clearDoneWithUndo() async {
    AppHaptics.warning();
    final bool? ok = await _confirmClear(context);
    if (ok != true || !mounted) return;

    // Snapshot fresco del estado actual (no del que capturó build).
    final List<ShoppingListItem> snapshot = ref
            .read(shoppingListProvider)
            .valueOrNull
            ?.where((ShoppingListItem i) => i.isChecked)
            .toList() ??
        const <ShoppingListItem>[];
    if (snapshot.isEmpty) return;

    await ref.read(shoppingListRepositoryProvider).clearCompleted();
    AppAnalytics.logShoppingListCleared().ignore();
    if (!mounted) return;
    final AppLocalizations t = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller =
        messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(t.cartClearedSnack(snapshot.length)),
        action: SnackBarAction(
          label: t.commonUndo,
          onPressed: () async {
            AppHaptics.tap();
            final ShoppingListRepository repo =
                ref.read(shoppingListRepositoryProvider);
            for (final ShoppingListItem it in snapshot) {
              await repo.restoreItem(it);
            }
          },
        ),
      ),
    );
    // Cierre forzado a los 3s: protege contra el caso donde `duration`
    // del SnackBar no se respeta (timers de a11y, focus, etc.).
    Future<void>.delayed(const Duration(seconds: 3), () {
      try {
        controller.close();
      } catch (_) {/* ya cerrado */}
    });
  }

  Future<void> _markSectionDone(List<ShoppingListItem> pending) async {
    if (pending.isEmpty) return;
    AppHaptics.confirm();
    await ref.read(shoppingListRepositoryProvider).markManyChecked(
          pending.map((ShoppingListItem i) => i.id).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(shoppingListSyncProvider);

    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final AsyncValue<List<ShoppingListItem>> async =
        ref.watch(shoppingListProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            t.commonError,
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
                t: t,
                onClearDone: done.isEmpty ? null : _clearDoneWithUndo,
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
                  child: _Empty(palette: p, t: t),
                )
              else ...<Widget>[
                if (pending.isNotEmpty)
                  ..._buildPendingSlivers(pendingGrouped, p),
                if (done.isNotEmpty) ...<Widget>[
                  _SectionHeader(
                    title: t.cartSectionDone,
                    caption: t.cartSectionDoneSubtitle,
                    color: AppColors.successStrong,
                    count: done.length,
                  ),
                  _ItemsList(
                    items: done,
                    palette: p,
                    onDelete: _deleteWithUndo,
                    onEdit: (ShoppingListItem item) =>
                        _showEditSheet(context, item),
                  ),
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

    final AppLocalizations t = AppLocalizations.of(context);
    return <Widget>[
      for (final MapEntry<String?, List<ShoppingListItem>> e in entries) ...<Widget>[
        _SectionHeader(
          title: e.key ?? t.cartSectionToBuy,
          caption: e.key == null
              ? t.cartSectionManual
              : t.cartSectionRecipe,
          color: e.key == null ? p.brandPrimary : AppColors.warningStrong,
          count: e.value.length,
          onMarkAll: () => _markSectionDone(e.value),
          onRecipeTap: e.key == null
              ? null
              : () {
                  final String? recipeId = e.value.first.sourceRecipeId;
                  if (recipeId == null) return;
                  AppHaptics.tap();
                  context.push('${AppRoutes.recipes}/$recipeId');
                },
        ),
        _ItemsList(
          items: e.value,
          palette: p,
          onDelete: _deleteWithUndo,
          onEdit: (ShoppingListItem item) => _showEditSheet(context, item),
        ),
      ],
    ];
  }

  Future<bool?> _confirmClear(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        title: Text(t.cartClearDoneTitle),
        content: Text(t.cartClearDoneBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerStrong),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.commonDelete),
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
    required this.t,
    required this.onClearDone,
  });

  final int total;
  final int pending;
  final int done;
  final AppLocalizations t;
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
                    tooltip: t.cartClearDoneTooltip,
                    onTap: onClearDone!,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.cartTitle,
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == 0
                  ? t.cartEmpty
                  : pending == 0
                      ? t.cartAllDone
                      : t.cartPendingCount(pending),
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    label: t.cartStatTotal,
                    count: total,
                    icon: Icons.shopping_basket_outlined,
                    accent: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: t.cartStatPending,
                    count: pending,
                    icon: Icons.radio_button_unchecked_rounded,
                    accent: const Color(0xFFFFE0B2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryChip(
                    label: t.cartStatDone,
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
                hintText: AppLocalizations.of(context).cartQuickAddHint,
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
    this.onMarkAll,
    this.onRecipeTap,
  });

  final String title;
  final String caption;
  final Color color;
  final int count;
  final VoidCallback? onMarkAll;
  final VoidCallback? onRecipeTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    final Widget titleAndCaption = Column(
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
            if (onRecipeTap != null) ...<Widget>[
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new_rounded,
                size: 13,
                color: p.textMuted,
              ),
            ],
          ],
        ),
        const SizedBox(height: 1),
        Text(
          caption,
          style: AppTypography.bodyXs.copyWith(color: p.textMuted),
        ),
      ],
    );

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
              child: onRecipeTap == null
                  ? titleAndCaption
                  : InkWell(
                      borderRadius: AppRadius.brMd,
                      onTap: onRecipeTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 2,
                        ),
                        child: titleAndCaption,
                      ),
                    ),
            ),
            if (onMarkAll != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadius.brPill,
                    onTap: onMarkAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brPill,
                        border: Border.all(
                          color: color.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.done_all_rounded, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).cartMarkAll,
                            style: AppTypography.labelSm.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
  const _ItemsList({
    required this.items,
    required this.palette,
    required this.onDelete,
    required this.onEdit,
  });

  final List<ShoppingListItem> items;
  final PaletteSpec palette;
  final ValueChanged<ShoppingListItem> onDelete;
  final ValueChanged<ShoppingListItem> onEdit;

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
            // Defer to next frame: el Dismissible se desmonta limpio
            // antes de que el stream emita y el padre reconstruya.
            onDismissed: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onDelete(item);
              });
            },
            child: _ItemTile(
              item: item,
              onEdit: () => onEdit(item),
            ),
          );
        },
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({required this.item, required this.onEdit});
  final ShoppingListItem item;
  final VoidCallback onEdit;

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
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onEdit();
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
                        color: checked ? p.textMuted : p.textBody,
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
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: p.textMuted,
                ),
                tooltip: AppLocalizations.of(context).cartEditTooltip,
                onPressed: () {
                  AppHaptics.tap();
                  onEdit();
                },
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
  const _Empty({required this.palette, required this.t});
  final PaletteSpec palette;
  final AppLocalizations t;

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
              t.cartEmptyTitle,
              style: AppTypography.headingMd.copyWith(color: palette.textBody),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.cartEmptyHint,
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

// ─────────────────────────────────────────────────────────────────────────────
// Edit sheet — StatefulWidget para manejar controllers de forma segura
// ─────────────────────────────────────────────────────────────────────────────
class _EditResult {
  const _EditResult.save({required this.name, required this.quantity})
      : delete = false;
  const _EditResult.delete()
      : name = '',
        quantity = null,
        delete = true;
  final String name;
  final String? quantity;
  final bool delete;
}

class _EditItemSheet extends StatefulWidget {
  const _EditItemSheet({required this.item});
  final ShoppingListItem item;

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _qtyCtrl = TextEditingController(text: widget.item.quantity ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final String qty = _qtyCtrl.text.trim();
    Navigator.of(context).pop(
      _EditResult.save(name: name, quantity: qty.isEmpty ? null : qty),
    );
  }

  void _requestDelete() {
    Navigator.of(context).pop(const _EditResult.delete());
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: p.outline,
                  borderRadius: AppRadius.brPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    t.cartEditItemTitle,
                    style: AppTypography.headingSm.copyWith(
                      color: p.textBody,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 22),
                  color: AppColors.dangerStrong,
                  tooltip: t.cartDeleteItemTooltip,
                  onPressed: _requestDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: t.cartEditNameLabel,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: p.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: p.outline),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _qtyCtrl,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: InputDecoration(
                labelText: t.cartEditQtyLabel,
                hintText: t.cartEditQtyHint,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: p.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: p.outline),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: p.outline),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.brLg,
                      ),
                    ),
                    child: Text(
                      t.commonCancel,
                      style: TextStyle(color: p.textBody),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: p.brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.brLg,
                      ),
                    ),
                    child: Text(
                      t.commonSave,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
