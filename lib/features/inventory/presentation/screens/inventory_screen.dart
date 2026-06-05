import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/i18n/category_l10n.dart';
import '../../../../core/i18n/sort_l10n.dart';
import '../../../../core/presentation/widgets/app_background.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../models/pantry_card_item.dart';
import '../../domain/entities/sort_preference.dart';
import '../../../notifications/presentation/providers/notification_settings_providers.dart';
import '../providers/inventory_providers.dart';
import '../providers/sort_providers.dart';
import '../widgets/inventory_bottom_nav.dart';
import '../widgets/inventory_category_chips.dart';
import '../widgets/inventory_insights_card.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/inventory_top_bar.dart';
import '../widgets/sort_bottom_sheet.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  // Claves canónicas en español (deben coincidir con item.category en BD).
  // El UI usa categoryLabel() para mostrar la versión localizada.
  static const List<String> _chips = pantryCategoryKeys;

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
    ref.watch(lowStockWatcherProvider);
    ref.watch(expiryNotificationWatcherProvider);
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);

    final double topPad = MediaQuery.paddingOf(context).top;

    final List<InventoryItem> allItems = asyncItems.valueOrNull ?? <InventoryItem>[];
    final List<int> chipCounts = _chips.asMap().entries.map((MapEntry<int, String> e) {
      if (e.key == 0) return allItems.length;
      return allItems
          .where((InventoryItem item) =>
              (item.category ?? '').toLowerCase() == e.value.toLowerCase())
          .length;
    }).toList();

    final SortPreference sortPref = ref.watch(sortPreferenceProvider);

    return Scaffold(
      backgroundColor: p.scaffold,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton(
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
      ),
      bottomNavigationBar: InventoryBottomNav(
        onScanTap: () => context.push(AppRoutes.scanner),
        onNotifTap: () => context.push(AppRoutes.notificationSettings),
        onProfileTap: () => context.push(AppRoutes.profile),
        onRecipesTap: () => context.push(AppRoutes.recipes),
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
                        t.inventoryTitle,
                        style: AppTypography.displayHero.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        t.inventoryTagline,
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
                          hintText: t.inventorySearchHint,
                          hintStyle: AppTypography.bodyMd.copyWith(color: p.textMuted),
                          prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  tooltip: t.inventoryClearSearch,
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
                      const SizedBox(height: AppSpacing.sm + 2),
                      // Sort indicator + button
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                AppHaptics.tap();
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: p.surface,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (_) => const SortBottomSheet(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface,
                                  borderRadius: AppRadius.brPill,
                                  border: Border.all(color: p.outline),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.sort_rounded,
                                      size: 15,
                                      color: p.brandPrimary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      sortPref.criteria.label(context),
                                      style: AppTypography.labelSm.copyWith(
                                        color: p.brandPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(
                                      sortPref.ascending
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 13,
                                      color: p.brandPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      InventoryCategoryChips(
                        categories: _chips
                            .map((String c) => categoryLabel(context, c))
                            .toList(growable: false),
                        selectedIndex: _selectedChip,
                        onSelected: (int index) =>
                            setState(() => _selectedChip = index),
                        counts: chipCounts,
                      ),
                      const SizedBox(height: AppSpacing.ml),
                    ],
                  ),
                ),
              ),
              asyncItems.when(
                data: (List<InventoryItem> rows) {
                  // Category filter (index 0 = Todos)
                  final String selectedCategory =
                      _selectedChip == 0 ? '' : _chips[_selectedChip].toLowerCase();

                  List<InventoryItem> filtered = selectedCategory.isEmpty
                      ? rows
                      : rows
                          .where((InventoryItem e) =>
                              (e.category ?? '').toLowerCase() == selectedCategory)
                          .toList();

                  // Search filter on top of category filter
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered
                        .where((InventoryItem e) =>
                            e.name.toLowerCase().contains(_searchQuery) ||
                            (e.brand ?? '').toLowerCase().contains(_searchQuery) ||
                            (e.category ?? '').toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  // Sort
                  filtered = ref
                      .read(sortInventoryItemsUseCaseProvider)
                      .call(filtered, sortPref);

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 140),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: p.textMuted.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _searchQuery.isEmpty
                                  ? t.inventoryEmptyTitle
                                  : t.inventorySearchNoResults(_searchQuery),
                              style: AppTypography.bodyLg.copyWith(
                                color: p.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _searchQuery.isEmpty
                                  ? t.inventoryEmptyHint
                                  : t.inventorySearchTryOther,
                              style: AppTypography.bodySm.copyWith(
                                color: p.textMuted.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  t.commonDelete,
                                  style: const TextStyle(
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
                                title: Text(t.inventoryDeleteTitle),
                                content: Text(
                                  t.inventoryDeleteBody(item.name),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text(t.commonCancel),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.dangerStrong,
                                    ),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: Text(t.commonDelete),
                                  ),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (_) {
                            AppHaptics.error();
                            // Defer al siguiente frame: el Dismissible se
                            // desmonta limpio antes de que el stream emita y
                            // dispare el rebuild que evidencia el race.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref
                                  .read(deleteInventoryItemUseCaseProvider)
                                  .call(item.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadius.brMd,
                                    ),
                                    content: Text(
                                      t.inventoryDeletedSnack(item.name),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    action: SnackBarAction(
                                      label: t.commonUndo,
                                      onPressed: () {
                                        ref
                                            .read(
                                                saveInventoryItemUseCaseProvider)
                                            .call(item);
                                      },
                                    ),
                                  ),
                                );
                            });
                          },
                          child: InventoryProductCard(
                            item: _toPantryCard(item),
                            onIncrement: () => _handleIncrement(item),
                            onDecrement: () => _handleDecrement(item),
                            onTap: () => context
                                .push('${AppRoutes.productDetail}/${item.id}'),
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
                      t.inventoryLoadError,
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
      final AppLocalizations t = AppLocalizations.of(context);
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
          title: Text(t.inventoryConfirmDeleteTitle),
          content: Text(t.inventoryConfirmDeleteBody(item.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.dangerStrong),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.commonDelete),
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

    final AppLocalizations t = AppLocalizations.of(context);
    return PantryCardItem(
      name: item.name,
      // La categoría canónica (en español) se preserva si existe; solo
      // localizamos el placeholder cuando no hay categoría asignada.
      category: item.category ?? t.categoryUncategorized,
      quantity: '${item.quantity} ${item.quantity == 1 ? t.unitOne : t.unitMany}',
      rawQuantity: item.quantity,
      daysLeft: daysLeft,
      progress: progress,
      status: status,
      imageUrl: item.imageUrl ?? '',
    );
  }
}
