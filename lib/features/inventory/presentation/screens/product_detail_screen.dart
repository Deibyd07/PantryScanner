import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../shopping_list/presentation/providers/shopping_list_providers.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AsyncValue<List<InventoryItem>> async =
        ref.watch(inventoryItemsProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text(
            'No se pudo cargar el producto',
            style: AppTypography.bodyMd.copyWith(color: p.textMuted),
          ),
        ),
        data: (List<InventoryItem> items) {
          final InventoryItem? item =
              items.cast<InventoryItem?>().firstWhere(
                    (InventoryItem? i) => i?.id == itemId,
                    orElse: () => null,
                  );
          if (item == null) {
            return _NotFound(palette: p);
          }
          return _Body(item: item);
        },
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.palette});
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Spacer(),
            Icon(Icons.inventory_2_outlined,
                size: 64, color: palette.textMuted.withValues(alpha: 0.35)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Este producto ya no está en tu despensa',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(color: palette.textMuted),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _Hero(item: item)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StatsRow(item: item),
                const SizedBox(height: AppSpacing.lg),
                _QuantityCard(item: item),
                const SizedBox(height: AppSpacing.lg),
                _DetailsCard(item: item),
                if (item.notes != null && item.notes!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _NotesCard(notes: item.notes!),
                ],
                const SizedBox(height: AppSpacing.lg),
                _ActionsCard(item: item),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero — full-bleed image (or category gradient) + back btn + status badge
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    final Color statusColor = _statusColor(item.status);

    return SizedBox(
      height: 280 + topPad,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: _HeroImage(item: item)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const <double>[0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + AppSpacing.sm,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Row(
              children: <Widget>[
                _CircleBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                _StatusBadge(status: item.status, color: statusColor),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (item.category != null && item.category!.isNotEmpty)
                  Text(
                    item.category!.toUpperCase(),
                    style: AppTypography.labelSm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: AppTypography.displaySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (item.brand != null && item.brand!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    item.brand!,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final String? url = item.imageUrl;
    final Color statusColor = _statusColor(item.status);

    Widget fallback() => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                statusColor.withValues(alpha: 0.85),
                statusColor.withValues(alpha: 0.55),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.kitchen_outlined,
              color: Colors.white70,
              size: 84,
            ),
          ),
        );

    if (url == null || url.isEmpty) return fallback();

    if (!url.startsWith('http')) {
      if (kIsWeb) {
        return Image.network(url,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
      }
      return Image.file(File(url),
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback());
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
      loadingBuilder: (BuildContext _, Widget child,
              ImageChunkEvent? progress) =>
          progress == null ? child : fallback(),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final ProductStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_statusIcon(status), size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            _statusLabel(status),
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

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final int? daysLeft =
        item.expiryDate?.difference(DateTime.now()).inDays;

    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            icon: Icons.inventory_2_outlined,
            value: '${item.quantity}',
            unit: item.quantity == 1 ? 'unidad' : 'unidades',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.schedule_rounded,
            value: daysLeft == null
                ? '—'
                : daysLeft < 0
                    ? '${daysLeft.abs()}'
                    : '$daysLeft',
            unit: daysLeft == null
                ? 'sin vencimiento'
                : daysLeft < 0
                    ? 'días vencido'
                    : daysLeft == 0
                        ? 'vence hoy'
                        : daysLeft == 1
                            ? 'día restante'
                            : 'días restantes',
            color: daysLeft != null && daysLeft <= 0
                ? AppColors.dangerStrong
                : daysLeft != null && daysLeft <= 3
                    ? AppColors.warningStrong
                    : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.notifications_active_outlined,
            value: '${item.minStock}',
            unit: 'stock mín.',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.unit,
    this.color,
  });

  final IconData icon;
  final String value;
  final String unit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final Color tone = color ?? p.brandPrimary;
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
          Icon(icon, size: 20, color: tone),
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
            textAlign: TextAlign.center,
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
// Quantity card (stepper)
// ─────────────────────────────────────────────────────────────────────────────
class _QuantityCard extends ConsumerWidget {
  const _QuantityCard({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Cantidad',
      icon: Icons.tune_rounded,
      caption: 'Ajusta cuántas unidades tienes',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${item.quantity}',
              style: AppTypography.displayMd.copyWith(
                color: context.palette.textBody,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              children: <Widget>[
                _StepBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => _decrement(context, ref),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StepBtn(
                  icon: Icons.add_rounded,
                  onTap: () => _increment(ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _increment(WidgetRef ref) async {
    AppHaptics.confirm();
    await ref
        .read(updateInventoryItemQuantityUseCaseProvider)
        .call(item, 1);
  }

  Future<void> _decrement(BuildContext context, WidgetRef ref) async {
    if (item.quantity <= 1) {
      AppHaptics.warning();
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
          title: const Text('¿Eliminar producto?'),
          content: Text(
            'La cantidad de "${item.name}" llegará a 0. ¿Quieres eliminarlo del inventario?',
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
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        AppHaptics.error();
        await ref.read(deleteInventoryItemUseCaseProvider).call(item.id);
        if (context.mounted) Navigator.of(context).pop();
      }
      return;
    }
    AppHaptics.confirm();
    await ref
        .read(updateInventoryItemQuantityUseCaseProvider)
        .call(item, -1);
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brPill,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: p.brandPrimary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: p.brandPrimary, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Details card (read-only fields)
// ─────────────────────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final List<_DetailRow> rows = <_DetailRow>[
      _DetailRow(
        icon: Icons.qr_code_2_rounded,
        label: 'Código de barras',
        value: item.barcode.isEmpty ? 'Sin código' : item.barcode,
      ),
      _DetailRow(
        icon: Icons.category_outlined,
        label: 'Categoría',
        value: item.category ?? 'Sin categoría',
      ),
      _DetailRow(
        icon: Icons.event_outlined,
        label: 'Vencimiento',
        value: item.expiryDate == null
            ? 'No registrado'
            : DateFormat('d MMM y', 'es').format(item.expiryDate!),
      ),
      _DetailRow(
        icon: Icons.add_circle_outline_rounded,
        label: 'Agregado',
        value: DateFormat('d MMM y', 'es').format(item.createdAt),
      ),
      _DetailRow(
        icon: Icons.update_rounded,
        label: 'Última edición',
        value: DateFormat('d MMM y', 'es').format(item.updatedAt),
      ),
    ];

    return _SectionCard(
      title: 'Detalles',
      icon: Icons.info_outline_rounded,
      caption: 'Información del producto',
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) Divider(color: p.outlineSoft, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
              child: Row(
                children: <Widget>[
                  Icon(rows[i].icon, size: 18, color: p.textMuted),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style: AppTypography.bodySm.copyWith(
                        color: p.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    rows[i].value,
                    style: AppTypography.bodySm.copyWith(
                      color: p.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notes card
// ─────────────────────────────────────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return _SectionCard(
      title: 'Notas',
      icon: Icons.notes_rounded,
      caption: 'Tus apuntes sobre este producto',
      child: Text(
        notes,
        style: AppTypography.bodyMd.copyWith(
          color: p.textBody,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions card
// ─────────────────────────────────────────────────────────────────────────────
class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.item});
  final InventoryItem item;

  bool get _needsReplenish =>
      item.status == ProductStatus.outOfStock ||
      item.status == ProductStatus.expired ||
      item.quantity <= item.minStock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    return Column(
      children: <Widget>[
        if (_needsReplenish) ...<Widget>[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _addToShoppingList(context, ref),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text('Reponer · añadir al carrito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: p.brandPrimary,
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
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                AppHaptics.tap();
                context.push(
                  '${AppRoutes.productForm}?barcode=${item.barcode}',
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text('Editar producto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.brandPrimary,
                side: BorderSide(color: p.brandPrimary.withValues(alpha: 0.5)),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brLg,
                ),
                textStyle: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else ...<Widget>[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                AppHaptics.tap();
                context.push(
                  '${AppRoutes.productForm}?barcode=${item.barcode}',
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text('Editar producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: p.brandPrimary,
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
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _addToShoppingList(context, ref),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text('Añadir al carrito'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.textBody,
                side: BorderSide(color: p.outline),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brLg,
                ),
                textStyle: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text('Eliminar producto'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerStrong,
              side: BorderSide(
                color: AppColors.dangerStrong.withValues(alpha: 0.45),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brLg,
              ),
              textStyle: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addToShoppingList(BuildContext context, WidgetRef ref) async {
    AppHaptics.confirm();
    final String target = item.name.toLowerCase().trim();
    final bool alreadyExisted = ref
            .read(shoppingListProvider)
            .valueOrNull
            ?.any((i) =>
                !i.isChecked &&
                i.sourceRecipeId == null &&
                i.name.toLowerCase().trim() == target) ??
        false;
    await ref.read(shoppingListRepositoryProvider).addItem(name: item.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: alreadyExisted
              ? const Color(0xFFB45309)
              : const Color(0xFF166534),
          content: Text(
            alreadyExisted
                ? 'Ya tenías "${item.name}" en tu carrito'
                : 'Añadiste "${item.name}" al carrito',
            style: const TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.shoppingList),
          ),
        ),
      );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    AppHaptics.warning();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que quieres eliminar "${item.name}" de tu despensa?',
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      AppHaptics.error();
      await ref.read(deleteInventoryItemUseCaseProvider).call(item.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section card
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.caption,
    required this.child,
  });
  final String title;
  final IconData icon;
  final String caption;
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

// ─────────────────────────────────────────────────────────────────────────────
// Status helpers
// ─────────────────────────────────────────────────────────────────────────────
Color _statusColor(ProductStatus s) {
  switch (s) {
    case ProductStatus.expired:
      return AppColors.dangerStrong;
    case ProductStatus.expiringSoon:
      return AppColors.warningStrong;
    case ProductStatus.outOfStock:
      return AppColors.neutralStrong;
    case ProductStatus.normal:
      return AppColors.successStrong;
  }
}

String _statusLabel(ProductStatus s) {
  switch (s) {
    case ProductStatus.expired:
      return 'Vencido';
    case ProductStatus.expiringSoon:
      return 'Vence pronto';
    case ProductStatus.outOfStock:
      return 'Sin stock';
    case ProductStatus.normal:
      return 'Fresco';
  }
}

IconData _statusIcon(ProductStatus s) {
  switch (s) {
    case ProductStatus.expired:
      return Icons.cancel_outlined;
    case ProductStatus.expiringSoon:
      return Icons.timer_outlined;
    case ProductStatus.outOfStock:
      return Icons.remove_shopping_cart_outlined;
    case ProductStatus.normal:
      return Icons.check_circle_outline;
  }
}
