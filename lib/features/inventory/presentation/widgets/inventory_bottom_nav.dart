import 'package:flutter/material.dart';

import 'inventory_tokens.dart';

class InventoryBottomNav extends StatelessWidget {
  const InventoryBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7EE).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A154212),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _BottomNavIcon(icon: Icons.inventory_2_rounded, active: true),
            _BottomNavIcon(icon: Icons.photo_camera_outlined),
            _BottomNavIcon(icon: Icons.restaurant_menu_outlined),
            _BottomNavIcon(icon: Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: InventoryTokens.primary,
          ),
          child: const Icon(Icons.inventory_2_rounded, color: Colors.white),
        ),
      );
    }

    return Icon(icon, color: InventoryTokens.textMuted);
  }
}
