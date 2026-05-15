import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'inventory_tokens.dart';

class InventoryTopBar extends ConsumerWidget {
  const InventoryTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: InventoryTokens.bg.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded),
          ),
          Expanded(
            child: Text(
              'PANTRY SCANNER',
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          // User avatar with logout menu
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (String value) async {
              if (value == 'notification-settings') {
                context.push(AppRoutes.notificationSettings);
                return;
              }
              if (value == 'logout') {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                        '¿Estás seguro de que deseas cerrar tu sesión?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE53E3E),
                        ),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(logoutUseCaseProvider).call();
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?.displayName ?? 'Usuario',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'notification-settings',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.notifications_none_rounded,
                        size: 20, color: InventoryTokens.secondary),
                    SizedBox(width: 10),
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: InventoryTokens.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.logout_rounded, size: 20, color: Color(0xFFE53E3E)),
                    SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Color(0xFFE53E3E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: InventoryTokens.primary.withValues(alpha: 0.12),
                ),
              ),
              child: ClipOval(
                child: user?.photoUrl != null
                    ? Image.network(
                        user!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallback(user),
                      )
                    : _buildFallback(user),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(dynamic user) {
    final String initial =
        user != null ? (user.initials ?? '?') : '?';
    return Container(
      color: const Color(0xFF1F7A5A),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[
            InventoryTokens.brand,
            InventoryTokens.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: InventoryTokens.brand.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: InventoryTokens.bg,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: user?.photoUrl != null
              ? Image.network(
                  user.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    final String initial = user != null ? (user.initials ?? '?') : '?';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[InventoryTokens.brand, InventoryTokens.brandDark],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.epilogue(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}
