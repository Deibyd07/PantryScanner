import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/presentation/widgets/app_background.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../domain/entities/inventory_item.dart';
import '../models/pantry_card_item.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_bottom_nav.dart';
import '../widgets/inventory_category_chips.dart';
import '../widgets/inventory_insights_card.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/inventory_top_bar.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final List<String> _chips = <String>[
    'Todos',
    'Lácteos',
    'Carnes',
    'Frutas y verduras',
    'Enlatados',
    'Bebidas',
    'Snacks',
    'Cereales',
    'Condimentos',
  ];

  int _selectedChip = 0;
  String _searchQuery = '';

  // ── HU-07: search with debounce ────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<InventoryItem>> asyncItems = ref.watch(inventoryItemsProvider);
    final PaletteSpec p = context.palette;

    final double topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: p.scaffold,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppHaptics.confirm();
          context.push(AppRoutes.productForm);
        },
        backgroundColor: p.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: InventoryBottomNav(
        onScanTap: () => context.push(AppRoutes.scanner),
        onNotifTap: () => context.push(AppRoutes.notificationSettings),
      ),
      body: Stack(
        children: <Widget>[
          // Doodle background (capa base)
          const Positioned.fill(
            child: AppBackground(overlayOpacity: 0.93),
          ),
          // Gradient hero (identidad de marca — encima del doodle)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400 + topPad,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              const InventoryTopBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Mi despensa',
                        style: AppTypography.displayHero.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        'Organiza · Controla · Ahorra',
                        style: AppTypography.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.ml),
                      const InventoryInsightsCard(),
                      const SizedBox(height: AppSpacing.xl - 4),
                      TextField(
                        controller: _searchCtrl,
                        style: AppTypography.bodyMd.copyWith(color: p.textBody),
                        onChanged: (String value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            AppDuration.debounce,
                            () => setState(
                              () => _searchQuery = value.trim().toLowerCase(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Busca en tu despensa...',
                          hintStyle: AppTypography.bodyMd.copyWith(color: p.textMuted),
                          prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  tooltip: 'Limpiar búsqueda',
                                  color: p.textMuted,
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: p.surface,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.brLg,
                            borderSide: BorderSide(color: p.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.brLg,
                            borderSide: BorderSide(color: p.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.brLg,
                            borderSide: BorderSide(
                              color: p.brandPrimary,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md + 2),
                      InventoryCategoryChips(
                        categories: _chips,
                        selectedIndex: _selectedChip,
                        onSelected: (int index) =>
                            setState(() => _selectedChip = index),
                      ),
                      const SizedBox(height: AppSpacing.ml),
                    ],
                  ),
                ),
              ),
              asyncItems.when(
                data: (List<InventoryItem> rows) {
                  final List<InventoryItem> filtered = _searchQuery.isEmpty
                      ? rows
                      : rows
                          .where((InventoryItem e) =>
                              e.name.toLowerCase().contains(_searchQuery) ||
                              (e.brand ?? '').toLowerCase().contains(_searchQuery) ||
                              (e.category ?? '').toLowerCase().contains(_searchQuery))
                          .toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: p.textMuted.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Tu despensa está vacía'
                                  : 'Sin resultados para "$_searchQuery"',
                              style: AppTypography.bodyLg.copyWith(
                                color: p.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Agrega tu primer producto escaneando un código'
                                  : 'Intenta con otro nombre, marca o categoría',
                              style: AppTypography.bodySm.copyWith(
                                color: p.textMuted.withValues(alpha: 0.6),
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...<Widget>[
                              const SizedBox(height: AppSpacing.lg),
                              FilledButton.icon(
                                onPressed: () => context.push(AppRoutes.scanner),
                                style: FilledButton.styleFrom(
                                  backgroundColor: p.brandPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.ms,
                                  ),
                                ),
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Escanear mi primer producto'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 140),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.ms),
                      itemBuilder: (BuildContext context, int index) {
                        final InventoryItem item = filtered[index];
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
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.delete_outline, color: Colors.white, size: 28),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (_) async {
                            AppHaptics.warning();
                            return await showDialog<bool>(
                              context: context,
                              builder: (BuildContext ctx) => AlertDialog(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.brXl,
                                ),
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
                                      backgroundColor: AppColors.dangerStrong,
                                    ),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (_) {
                            AppHaptics.error();
                            ref
                                .read(deleteInventoryItemUseCaseProvider)
                                .call(item.id);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 5),
                                  behavior: SnackBarBehavior.floating,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.brMd,
                                  ),
                                  content: Text(
                                    '"${item.name}" eliminado',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  action: SnackBarAction(
                                    label: 'Deshacer',
                                    onPressed: () {
                                      ref
                                          .read(saveInventoryItemUseCaseProvider)
                                          .call(item);
                                    },
                                  ),
                                ),
                              );
                          },
                          child: InventoryProductCard(
                            item: _toPantryCard(item),
                            onIncrement: () => _handleIncrement(item),
                            onDecrement: () => _handleDecrement(item),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (Object err, StackTrace st) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No se pudo cargar el inventario',
                      style: AppTypography.bodyMd.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ── Offline indicator ─────────────────────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineBanner(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleIncrement(InventoryItem item) async {
    AppHaptics.confirm();
    await ref
        .read(updateInventoryItemQuantityUseCaseProvider)
        .call(item, 1);
  }

  Future<void> _handleDecrement(InventoryItem item) async {
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.dangerStrong),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        AppHaptics.error();
        ref.read(deleteInventoryItemUseCaseProvider).call(item.id);
      }
      return;
    }
    AppHaptics.confirm();
    await ref
        .read(updateInventoryItemQuantityUseCaseProvider)
        .call(item, -1);
  }

  PantryCardItem _toPantryCard(InventoryItem item) {
    final ProductStatus status = item.status;
    int daysLeft = 0;
    double progress = 1.0;

    if (item.expiryDate != null) {
      daysLeft = item.expiryDate!.difference(DateTime.now()).inDays.clamp(0, 30);
      progress = (daysLeft / 14.0).clamp(0.0, 1.0);
    } else if (status == ProductStatus.normal) {
      daysLeft = 30;
      progress = 1.0;
    }

    return PantryCardItem(
      name: item.name,
      category: item.category ?? 'Sin categoría',
      quantity: '${item.quantity} ${item.quantity == 1 ? 'unidad' : 'unidades'}',
      rawQuantity: item.quantity,
      daysLeft: daysLeft,
      progress: progress,
      status: status,
      imageUrl: item.imageUrl ?? '',
    );
  }
}
