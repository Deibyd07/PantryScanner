import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AsyncValue<AppUser?> userAsync = ref.watch(authStateProvider);
    final AsyncValue<List<InventoryItem>> itemsAsync =
        ref.watch(inventoryItemsProvider);

    final AppUser? user = userAsync.valueOrNull;
    final List<InventoryItem> items = itemsAsync.valueOrNull ?? <InventoryItem>[];

    final int totalProducts = items.length;
    final int totalCategories = items
        .map((InventoryItem i) => i.category ?? '')
        .where((String c) => c.isNotEmpty)
        .toSet()
        .length;
    final int withPhoto = items
        .where((InventoryItem i) => (i.imageUrl ?? '').isNotEmpty)
        .length;

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: <Widget>[
          _ProfileHero(user: user),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _StatsCard(
                  totalProducts: totalProducts,
                  totalCategories: totalCategories,
                  withPhoto: withPhoto,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountCard(user: user),
                const SizedBox(height: AppSpacing.md),
                _PreferencesCard(),
                const SizedBox(height: AppSpacing.md),
                _AboutCard(),
                const SizedBox(height: AppSpacing.lg),
                _LogoutButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero: gradient + avatar grande + nombre + email
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    final String displayName = user?.displayName ?? 'Usuario';
    final String email = user?.email ?? '';
    final String? photoUrl = user?.photoUrl;
    final String initial = user?.initials ?? '?';
    final bool isGoogle = user?.provider == AppAuthProvider.google;

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
          AppSpacing.xl,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleIconBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    context.pop();
                  },
                ),
                const Spacer(),
                Text(
                  'Mi perfil',
                  style: AppTypography.headingSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AvatarFallback(initial: initial),
                      )
                    : _AvatarFallback(initial: initial),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              displayName,
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              email,
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: AppRadius.brPill,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isGoogle ? Icons.g_mobiledata_rounded : Icons.email_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGoogle ? 'Cuenta Google' : 'Cuenta con correo',
                    style: AppTypography.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.displaySm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 36,
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
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
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card shells
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.brandTintSoft,
                  borderRadius: AppRadius.brMs,
                ),
                child: Icon(icon, color: p.brandPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
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
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: AppTypography.bodyXs.copyWith(color: p.textMuted),
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
// Stats card
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalProducts,
    required this.totalCategories,
    required this.withPhoto,
  });

  final int totalProducts;
  final int totalCategories;
  final int withPhoto;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md + 2,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatTile(
              value: '$totalProducts',
              label: 'Productos',
              icon: Icons.inventory_2_outlined,
              color: p.brandPrimary,
            ),
          ),
          _VerticalDivider(color: p.divider),
          Expanded(
            child: _StatTile(
              value: '$totalCategories',
              label: 'Categorías',
              icon: Icons.category_outlined,
              color: AppColors.warningStrong,
            ),
          ),
          _VerticalDivider(color: p.divider),
          Expanded(
            child: _StatTile(
              value: '$withPhoto',
              label: 'Con foto',
              icon: Icons.photo_camera_outlined,
              color: AppColors.successStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Column(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.brMs,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.headingLg.copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.labelTab.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: color,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account card
// ─────────────────────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});
  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tu cuenta',
      subtitle: 'Información del usuario conectado',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: user?.email ?? '—',
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Nombre',
            value: user?.displayName ?? '—',
          ),
          _RowDivider(),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Tipo de cuenta',
            value: user?.provider == AppAuthProvider.google
                ? 'Google'
                : 'Correo y contraseña',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences card
// ─────────────────────────────────────────────────────────────────────────────
class _PreferencesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Preferencias',
      subtitle: 'Personaliza la app a tu gusto',
      icon: Icons.tune_rounded,
      child: Column(
        children: <Widget>[
          _ActionRow(
            icon: Icons.notifications_outlined,
            label: 'Alertas y notificaciones',
            trailing: Icons.chevron_right_rounded,
            onTap: () {
              AppHaptics.tap();
              context.push(AppRoutes.notificationSettings);
            },
          ),
          _RowDivider(),
          _ActionRow(
            icon: Icons.dark_mode_outlined,
            label: 'Tema',
            valueChip: 'Automático',
            onTap: () {
              AppHaptics.tap();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Pronto: selector de tema'),
                ),
              );
            },
          ),
          _RowDivider(),
          _ActionRow(
            icon: Icons.language_outlined,
            label: 'Idioma',
            valueChip: 'Español',
            onTap: () {
              AppHaptics.tap();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Pronto: más idiomas'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About card
// ─────────────────────────────────────────────────────────────────────────────
class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Acerca de',
      subtitle: 'Información de la aplicación',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: <Widget>[
          const _InfoRow(
            icon: Icons.tag_rounded,
            label: 'Versión',
            value: '0.1.0',
          ),
          _RowDivider(),
          _ActionRow(
            icon: Icons.description_outlined,
            label: 'Términos y condiciones',
            trailing: Icons.open_in_new_rounded,
            onTap: () {
              AppHaptics.tap();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Pronto disponible'),
                ),
              );
            },
          ),
          _RowDivider(),
          _ActionRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Política de privacidad',
            trailing: Icons.open_in_new_rounded,
            onTap: () {
              AppHaptics.tap();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Pronto disponible'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable rows
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, color: p.textMuted, size: 18),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: p.textMuted,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMd.copyWith(
                color: p.textBody,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.valueChip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final IconData? trailing;
  final String? valueChip;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: <Widget>[
            Icon(icon, color: p.textMuted, size: 18),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: p.textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (valueChip != null) ...<Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceMuted,
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  valueChip!,
                  style: AppTypography.labelSm.copyWith(
                    color: p.textBody,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Icon(
              trailing ?? Icons.chevron_right_rounded,
              color: p.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      height: 1,
      color: p.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brXl,
        onTap: () => _confirmLogout(context, ref),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.dangerStrong.withValues(alpha: 0.08),
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: AppColors.dangerStrong.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.dangerStrong.withValues(alpha: 0.14),
                  borderRadius: AppRadius.brMs,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dangerStrong,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.dangerStrong,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.dangerStrong,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    AppHaptics.warning();
    final PaletteSpec p = context.palette;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        backgroundColor: p.surface,
        title: Text(
          'Cerrar sesión',
          style: AppTypography.headingSm.copyWith(color: p.textBody),
        ),
        content: Text(
          '¿Seguro que quieres cerrar tu sesión? Tendrás que iniciar sesión de nuevo.',
          style: AppTypography.bodyMd.copyWith(color: p.textBody),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerStrong,
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
}
