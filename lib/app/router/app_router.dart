import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router_key.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/product_form/presentation/screens/product_form_screen.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipes_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/settings/presentation/screens/legal_screen.dart';
import '../../features/shopping_list/presentation/screens/shopping_list_screen.dart';

class AppRoutes {
  static const String inventory = '/';
  static const String scanner = '/scanner';
  static const String productForm = '/product-form';
  static const String notificationSettings = '/notification-settings';
  static const String notificationsInbox = '/notifications-inbox';
  static const String profile = '/profile';
  static const String recipes = '/recipes';
  static const String productDetail = '/product';
  static const String shoppingList = '/shopping-list';
  static const String legalTerms = '/legal/terms';
  static const String legalPrivacy = '/legal/privacy';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
}

/// Auth-aware router that redirects unauthenticated users to login.
GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.inventory,
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);

      final bool isAuthenticated = authState.valueOrNull != null;
      final bool isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      // Still loading auth state — do nothing.
      if (authState.isLoading) return null;

      // Not authenticated → force login.
      if (!isAuthenticated && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      // Authenticated but on an auth page → go home.
      if (isAuthenticated && isOnAuthRoute) {
        return AppRoutes.inventory;
      }

      return null;
    },
    routes: <RouteBase>[
      // ── Auth routes ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),

      // ── Main app routes ────────────────────────────────────────────────────
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
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notification-settings',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationSettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.notificationsInbox,
        name: 'notifications-inbox',
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsInboxScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
      GoRoute(
        path: '${AppRoutes.productDetail}/:id',
        name: 'product-detail',
        builder: (BuildContext context, GoRouterState state) {
          final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailScreen(itemId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.recipes,
        name: 'recipes',
        builder: (BuildContext context, GoRouterState state) {
          return const RecipesScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            name: 'recipe-detail',
            builder: (BuildContext context, GoRouterState state) {
              final String id = state.pathParameters['id'] ?? '';
              return RecipeDetailScreen(recipeId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.shoppingList,
        name: 'shopping-list',
        builder: (BuildContext context, GoRouterState state) {
          return const ShoppingListScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.legalTerms,
        name: 'legal-terms',
        builder: (BuildContext context, GoRouterState state) {
          return LegalScreen.terms(context);
        },
      ),
      GoRoute(
        path: AppRoutes.legalPrivacy,
        name: 'legal-privacy',
        builder: (BuildContext context, GoRouterState state) {
          return LegalScreen.privacy(context);
        },
      ),
    ],
  );
}

/// Converts the Riverpod auth stream into a [ChangeNotifier] so GoRouter
/// can listen to auth state changes and re-evaluate its `redirect`.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
