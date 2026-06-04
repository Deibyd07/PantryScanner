typedef ParsedAdd = ({String name, String? quantity});

const Set<String> _units = <String>{
  'l', 'ml', 'kg', 'g', 'mg', 'oz', 'lb',
  'cda', 'cdas', 'cdita', 'cditas',
  'taza', 'tazas',
  'unidad', 'unidades', 'u', 'pza', 'pzas',
  'paq', 'paquete', 'paquetes',
  'lata', 'latas', 'botella', 'botellas',
  'docena', 'docenas',
  'caja', 'cajas', 'bolsa', 'bolsas',
};

/// Heurística para separar nombre y cantidad de un input libre.
///
/// Ejemplos:
///   "Leche 2 L"           → name=Leche, qty=2 L
///   "Pan 500 g"           → name=Pan, qty=500 g
///   "3 huevos"            → name=huevos, qty=3
///   "1 paquete de pan"    → name=pan, qty=1 paquete
///   "2L leche"            → name=leche, qty=2 L
///   "Aceite de oliva"     → name=Aceite de oliva, qty=null
ParsedAdd parseQuickAdd(String input) {
  final String s = input.trim();
  if (s.isEmpty) return (name: s, quantity: null);

  // Trailing: "Leche 2 L" / "Pan 500 g" / "Manzanas 6"
  final RegExpMatch? trailing = RegExp(
    r'^(.+?)\s+(\d+(?:[.,]\d+)?)\s*([a-záéíóúñ]+)?$',
    caseSensitive: false,
  ).firstMatch(s);
  if (trailing != null) {
    final String namePart = trailing.group(1)!.trim();
    final String num = trailing.group(2)!;
    final String? unitRaw = trailing.group(3);
    if (unitRaw == null) {
      return (name: namePart, quantity: num);
    }
    if (_units.contains(unitRaw.toLowerCase())) {
      return (name: namePart, quantity: '$num $unitRaw');
    }
  }

  // Leading: "3 huevos" / "1 paquete de tortillas" / "2L leche"
  final RegExpMatch? leading = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*([a-záéíóúñ]+)?\s+(?:de\s+)?(.+)$',
    caseSensitive: false,
  ).firstMatch(s);
  if (leading != null) {
    final String num = leading.group(1)!;
    final String? unitRaw = leading.group(2);
    final String rest = leading.group(3)!.trim();
    if (unitRaw != null && _units.contains(unitRaw.toLowerCase())) {
      return (name: rest, quantity: '$num $unitRaw');
    }
    if (unitRaw == null) {
      return (name: rest, quantity: num);
    }
  }

  return (name: s, quantity: null);
}
