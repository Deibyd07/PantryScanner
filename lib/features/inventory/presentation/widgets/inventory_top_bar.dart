import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'inventory_tokens.dart';

class InventoryTopBar extends StatelessWidget {
  const InventoryTopBar({super.key});

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: InventoryTokens.primary.withValues(alpha: 0.12)),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const ColoredBox(
                    color: Color(0xFFE9E9DD),
                    child: Icon(Icons.person, color: InventoryTokens.textMuted),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
