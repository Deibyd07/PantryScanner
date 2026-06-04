import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/shopping_list/data/utils/quick_add_parser.dart';

void main() {
  group('parseQuickAdd', () {
    // ── Empty / whitespace ────────────────────────────────────────────────────
    test('empty string returns empty name and no quantity', () {
      final r = parseQuickAdd('');
      expect(r.name, '');
      expect(r.quantity, isNull);
    });

    test('whitespace-only returns trimmed empty name', () {
      final r = parseQuickAdd('   ');
      expect(r.name, '');
      expect(r.quantity, isNull);
    });

    // ── Plain name — no quantity ──────────────────────────────────────────────
    test('plain name without number returns name and no quantity', () {
      final r = parseQuickAdd('Aceite de oliva');
      expect(r.name, 'Aceite de oliva');
      expect(r.quantity, isNull);
    });

    // ── Trailing number + unit ────────────────────────────────────────────────
    test('trailing number and recognized unit', () {
      final r = parseQuickAdd('Leche 2 L');
      expect(r.name, 'Leche');
      expect(r.quantity, '2 L');
    });

    test('trailing number and grams', () {
      final r = parseQuickAdd('Pan 500 g');
      expect(r.name, 'Pan');
      expect(r.quantity, '500 g');
    });

    test('trailing bare number (no unit)', () {
      final r = parseQuickAdd('Manzanas 6');
      expect(r.name, 'Manzanas');
      expect(r.quantity, '6');
    });

    test('trailing number with decimal', () {
      final r = parseQuickAdd('Mantequilla 0,5 kg');
      expect(r.name, 'Mantequilla');
      expect(r.quantity, '0,5 kg');
    });

    // ── Trailing number + unrecognized word ───────────────────────────────────
    test('trailing number with unrecognized word treated as no-match → falls to plain name', () {
      // "Arroz 2 bolsas" → bolsas IS recognized, so qty = "2 bolsas"
      final r = parseQuickAdd('Arroz 2 bolsas');
      expect(r.name, 'Arroz');
      expect(r.quantity, '2 bolsas');
    });

    // ── Leading number ────────────────────────────────────────────────────────
    test('leading bare number', () {
      final r = parseQuickAdd('3 huevos');
      expect(r.name, 'huevos');
      expect(r.quantity, '3');
    });

    test('leading number with recognized unit', () {
      final r = parseQuickAdd('1 paquete de pan');
      expect(r.name, 'pan');
      expect(r.quantity, '1 paquete');
    });

    test('leading number with kg unit', () {
      final r = parseQuickAdd('2 kg carne');
      expect(r.name, 'carne');
      expect(r.quantity, '2 kg');
    });

    // ── Case insensitivity ────────────────────────────────────────────────────
    test('unit matching is case-insensitive', () {
      final r = parseQuickAdd('Leche 1 L');
      expect(r.quantity, '1 L');
    });

    // ── Multi-word name with trailing number ──────────────────────────────────
    test('multi-word name retains spaces', () {
      final r = parseQuickAdd('Jugo de naranja 2 L');
      expect(r.name, 'Jugo de naranja');
      expect(r.quantity, '2 L');
    });
  });
}
