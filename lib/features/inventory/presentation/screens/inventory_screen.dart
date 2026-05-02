import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/entities/inventory_item.dart';
import '../models/pantry_card_item.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_bottom_nav.dart';
import '../widgets/inventory_category_chips.dart';
import '../widgets/inventory_insights_card.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/inventory_tokens.dart';
import '../widgets/inventory_top_bar.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final List<String> _chips = <String>[
    'Todo lo esencial',
    'Frutas y verduras',
    'Lácteos y huevos',
    'Granos',
    'Especias',
    'Proteínas',
  ];

  int _selectedChip = 0;
  String _searchQuery = '';


  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<InventoryItem>> asyncItems = ref.watch(inventoryItemsProvider);

    return Scaffold(
      backgroundColor: InventoryTokens.bg,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => context.push(AppRoutes.productForm),
        backgroundColor: InventoryTokens.accentContainer,
        foregroundColor: InventoryTokens.accentOnContainer,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 36),
      ),
      bottomNavigationBar: InventoryBottomNav(
        onScanTap: () => context.push(AppRoutes.scanner),
      ),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[InventoryTokens.bg, InventoryTokens.bgMuted],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              const InventoryTopBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Mi despensa',
                        style: GoogleFonts.epilogue(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -3.2,
                          color: InventoryTokens.primary,
                          height: 0.92,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const InventoryInsightsCard(),
                      const SizedBox(height: 24),
                      TextField(
                        onChanged: (String value) =>
                            setState(() => _searchQuery = value.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Busca en tu despensa...',
                          hintStyle: TextStyle(
                            color: InventoryTokens.textMuted.withValues(alpha: 0.55),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF5F4E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      InventoryCategoryChips(
                        categories: _chips,
                        selectedIndex: _selectedChip,
                        onSelected: (int index) =>
                            setState(() => _selectedChip = index),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // ── Product list as a proper Sliver (lazy, infinite scroll) ──
              asyncItems.when(
                data: (List<InventoryItem> rows) {
                  // Filter by search query
                  final List<InventoryItem> filtered = _searchQuery.isEmpty
                      ? rows
                      : rows
                          .where((InventoryItem e) =>
                              e.name.toLowerCase().contains(_searchQuery) ||
                              (e.category ?? '').toLowerCase().contains(_searchQuery))
                          .toList();

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: InventoryTokens.textMuted.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Tu despensa está vacía'
                                  : 'Sin resultados para "$_searchQuery"',
                              style: const TextStyle(
                                color: InventoryTokens.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Agrega tu primer producto escaneando un código'
                                  : 'Intenta con otro nombre o categoría',
                              style: TextStyle(
                                color: InventoryTokens.textMuted.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 320,
                          child: InventoryProductCard(
                            item: _toPantryCard(filtered[index]),
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
                error: (Object error, StackTrace stackTrace) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No se pudo cargar el inventario',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PantryCardItem _toPantryCard(InventoryItem item) {
    final ProductStatus status = item.status;

    // Days-to-expiry calculation for progress bar
    int daysLeft = 0;
    double progress = 1.0;

    if (item.expiryDate != null) {
      daysLeft = item.expiryDate!.difference(DateTime.now()).inDays.clamp(0, 30);
      progress = (daysLeft / 14.0).clamp(0.0, 1.0);
    } else if (status == ProductStatus.normal) {
      // No expiry — show full green bar
      daysLeft = 30;
      progress = 1.0;
    }

    return PantryCardItem(
      name: item.name,
      category: item.category ?? 'Sin categoría',
      quantity: '${item.quantity} ${item.quantity == 1 ? 'unidad' : 'unidades'}',
      daysLeft: daysLeft,
      progress: progress,
      status: status,
      imageUrl: item.imageUrl ??
          'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?q=80&w=1200&auto=format&fit=crop',
    );
  }
}
