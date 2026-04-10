import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/product_form/presentation/screens/product_form_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';

class AppRoutes {
  static const String inventory = '/';
  static const String scanner = '/scanner';
  static const String productForm = '/product-form';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.inventory,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.inventory,
      name: 'inventory',
      builder: (BuildContext context, GoRouterState state) {
        return const InventoryScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.scanner,
      name: 'scanner',
      builder: (BuildContext context, GoRouterState state) {
        return const ScannerScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.productForm,
      name: 'product-form',
      builder: (BuildContext context, GoRouterState state) {
        final String? barcode = state.uri.queryParameters['barcode'];
        return ProductFormScreen(initialBarcode: barcode);
      },
    ),
  ],
);
