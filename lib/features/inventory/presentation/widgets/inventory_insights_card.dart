import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'inventory_tokens.dart';

class InventoryInsightsCard extends StatelessWidget {
  const InventoryInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.42),
        border: Border.all(color: InventoryTokens.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: InventoryTokens.accentContainer,
                ),
                child: const Icon(Icons.auto_awesome, color: InventoryTokens.accentOnContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Resumen inteligente',
                      style: GoogleFonts.epilogue(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: InventoryTokens.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '3 productos vencen en menos de 48 horas',
                      style: TextStyle(
                        color: InventoryTokens.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: <Widget>[
              Expanded(
                child: _MetricTile(
                  value: '12%',
                  label: 'Tasa de desperdicio',
                  color: InventoryTokens.tertiary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  value: '84',
                  label: 'Total de productos',
                  color: InventoryTokens.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF5F4E8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            style: GoogleFonts.epilogue(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: InventoryTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
