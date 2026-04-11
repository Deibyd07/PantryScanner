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
    'Lacteos y huevos',
    'Granos',
    'Especias',
    'Proteinas',
  ];

  final List<PantryCardItem> _items = const <PantryCardItem>[
    PantryCardItem(
      name: 'Aguacates Hass',
      category: 'Frutas y verduras',
      quantity: '2 unidades',
      daysLeft: 2,
      progress: 0.85,
      highlight: true,
      imageUrl:
          'https://images.unsplash.com/photo-1601039641847-7857b994d704?q=80&w=1200&auto=format&fit=crop',
    ),
    PantryCardItem(
      name: 'Yogur griego',
      category: 'Lacteos',
      quantity: '1.5kg',
      daysLeft: 12,
      progress: 0.2,
      highlight: false,
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?q=80&w=1200&auto=format&fit=crop',
    ),
    PantryCardItem(
      name: 'Pan de masa madre',
      category: 'Panaderia',
      quantity: '1 pieza',
      daysLeft: 4,
      progress: 0.4,
      highlight: false,
      imageUrl:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=1200&auto=format&fit=crop',
    ),
  ];

  int _selectedChip = 0;

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
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
                        onSelected: (int index) => setState(() => _selectedChip = index),
                      ),
                      const SizedBox(height: 20),
                      asyncItems.when(
                        data: (List<InventoryItem> rows) {
                          final List<PantryCardItem> cards = rows.isEmpty
                              ? _items
                              : rows.map(_toPantryCard).toList();

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cards.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 0.86,
                              mainAxisSpacing: 16,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return InventoryProductCard(item: cards[index]);
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (Object error, StackTrace stackTrace) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No se pudo cargar el inventario',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    final int daysLeft = item.expiryDate == null
        ? 14
        : item.expiryDate!.difference(DateTime.now()).inDays.clamp(0, 30);

    final double progress = (daysLeft / 14).clamp(0.1, 1.0).toDouble();
    final bool highlight = item.status == ProductStatus.expiringSoon ||
        item.status == ProductStatus.expired;

    return PantryCardItem(
      name: item.name,
      category: item.category ?? 'Sin categoria',
      quantity: '${item.quantity} unidades',
      daysLeft: daysLeft,
      progress: progress,
      highlight: highlight,
      imageUrl: item.imageUrl ??
          'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?q=80&w=1200&auto=format&fit=crop',
    );
  }
}
