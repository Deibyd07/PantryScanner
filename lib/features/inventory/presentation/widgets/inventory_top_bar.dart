import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class InventoryTopBar extends ConsumerWidget {
  const InventoryTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final PaletteSpec p = context.palette;

    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: AppSpacing.ml,
      toolbarHeight: 64,
      title: Row(
        children: <Widget>[
          // Logo de marca: símbolo PNG transparente dentro de contenedor blanco
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.brMs,
              boxShadow: AppElevation.heroIcon,
            ),
            clipBehavior: Clip.antiAlias,
            child: Transform.scale(
              scale: 1.35,
              child: Image.asset(
                'assets/branding/icon_symbol.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'PantryScanner',
                style: AppTypography.headingSm.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                'Tu despensa, bajo control',
                style: AppTypography.bodyXs.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Botón notificaciones recibidas (inbox)
          IconButton(
            onPressed: () {
              AppHaptics.tap();
              context.push(AppRoutes.notificationsInbox);
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Avatar con menú
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.brLg,
              side: BorderSide(color: p.outline),
            ),
            color: p.surface,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            onSelected: (String value) async {
              if (value == 'logout') {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brXl,
                    ),
                    backgroundColor: p.surface,
                    title: Text(
                      'Cerrar sesión',
                      style: AppTypography.headingSm.copyWith(color: p.textBody),
                    ),
                    content: Text(
                      '¿Estás seguro de que deseas cerrar tu sesión?',
                      style: AppTypography.bodyMd.copyWith(color: p.textBody),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.dangerStrong,
                          minimumSize: const Size(0, 40),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.ms,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?.displayName ?? 'Usuario',
                      style: AppTypography.labelMd.copyWith(
                        color: p.textBody,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      user?.email ?? '',
                      style: AppTypography.bodyXs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.logout_rounded, size: 18, color: AppColors.dangerStrong),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Text(
                      'Cerrar sesión',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.dangerStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: _Avatar(user: user, palette: p),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.palette});

  final dynamic user;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    final String initial = user != null ? (user.initials ?? '?') : '?';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: ClipOval(
        child: user?.photoUrl != null
            ? Image.network(
                user!.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Fallback(initial: initial, palette: palette),
              )
            : _Fallback(initial: initial, palette: palette),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.initial, required this.palette});

  final String initial;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.brandPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.labelMd.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
