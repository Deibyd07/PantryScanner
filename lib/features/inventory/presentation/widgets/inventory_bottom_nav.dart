import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

class InventoryBottomNav extends StatelessWidget {
  const InventoryBottomNav({super.key, this.onScanTap, this.onNotifTap});

  final VoidCallback? onScanTap;
  final VoidCallback? onNotifTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        // ── White bar ─────────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(
              top: BorderSide(color: p.outlineSoft, width: 1),
            ),
            boxShadow: AppElevation.bottomBar,
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: <Widget>[
                  const Expanded(child: _NavItem(icon: Icons.inventory_2_rounded, label: 'Despensa', active: true)),
                  const Expanded(child: _NavItem(icon: Icons.restaurant_menu_outlined, label: 'Recetas')),
                  const SizedBox(width: 72),
                  Expanded(child: _NavItem(icon: Icons.tune_rounded, label: 'Alertas', onTap: onNotifTap)),
                  const Expanded(child: _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil')),
                ],
              ),
            ),
          ),
        ),
        // ── Elevated center scan button ────────────────────────────────────────
        Positioned(
          top: -26,
          child: GestureDetector(
            onTap: () {
              AppHaptics.confirm();
              onScanTap?.call();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
                border: Border.all(color: p.surface, width: 3),
                boxShadow: AppElevation.fabBrand(),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final Color color = active ? p.brandPrimary : p.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: active ? 24 : 22,
          ),
          const SizedBox(height: AppSpacing.xxs + 1),
          Text(
            label,
            style: AppTypography.labelTab.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: active ? 0.1 : 0,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs + 1),
          AnimatedContainer(
            duration: AppDuration.normal,
            width: active ? 16 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: p.brandPrimary,
              borderRadius: AppRadius.brPill,
            ),
          ),
        ],
      ),
    );
  }
}
