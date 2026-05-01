import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

// ─────────────────────────────────────────
// State notifier to handle async save state
// ─────────────────────────────────────────
class _SaveState {
  const _SaveState({this.isSaving = false, this.error});
  final bool isSaving;
  final String? error;
}

class _SaveNotifier extends StateNotifier<_SaveState> {
  _SaveNotifier(this._ref) : super(const _SaveState());

  final Ref _ref;

  Future<bool> save(InventoryItem item) async {
    state = const _SaveState(isSaving: true);
    try {
      await _ref.read(saveInventoryItemUseCaseProvider).call(item);
      state = const _SaveState();
      return true;
    } catch (e) {
      state = _SaveState(error: e.toString());
      return false;
    }
  }
}

final _saveNotifierProvider =
    StateNotifierProvider.autoDispose<_SaveNotifier, _SaveState>(
  (ref) => _SaveNotifier(ref),
);

// Categories are now managed in state for HU-18 preview

// ─────────────────────────────────────────
// Main screen widget (SUB-04.1)
// ─────────────────────────────────────────
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.initialBarcode});

  final String? initialBarcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Field values
  int _quantity = AppConstants.defaultQuantity; // default = 1
  DateTime? _expiryDate;
  String? _selectedCategory;

  // Categories state
  final List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[
    {'label': 'Lácteos', 'icon': Icons.egg_outlined},
    {'label': 'Carnes', 'icon': Icons.kebab_dining_outlined},
    {'label': 'Frutas y verduras', 'icon': Icons.eco_outlined},
    {'label': 'Enlatados', 'icon': Icons.inventory_2_outlined},
    {'label': 'Bebidas', 'icon': Icons.local_drink_outlined},
    {'label': 'Snacks', 'icon': Icons.fastfood_outlined},
    {'label': 'Cereales', 'icon': Icons.breakfast_dining_outlined},
    {'label': 'Condimentos', 'icon': Icons.soup_kitchen_outlined},
    {'label': 'Sin categoría', 'icon': Icons.category_outlined},
  ];

  // Animation
  late final AnimationController _headerAnim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      _barcodeController.text = widget.initialBarcode!;
    }

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  // ───── Build ─────
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final _SaveState saveState = ref.watch(_saveNotifierProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          // ── Floating App Bar ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Agregar producto',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Confirma los datos antes de guardar',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form body ──
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // ── Section: Información básica ──
                    _SectionHeader(title: 'Información básica', icon: Icons.info_outline_rounded),
                    const SizedBox(height: 12),
                    _buildNameField(colors),
                    const SizedBox(height: 12),
                    _buildBarcodeField(colors),

                    // ── Section: Categoría ──
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Categoría', icon: Icons.category_outlined),
                    const SizedBox(height: 12),
                    _buildCategoryPicker(colors),

                    // ── Section: Cantidad ──
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Cantidad', icon: Icons.production_quantity_limits_rounded),
                    const SizedBox(height: 12),
                    _buildQuantitySelector(colors),

                    // ── Section: Vencimiento ──
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Fecha de vencimiento', icon: Icons.event_rounded),
                    const SizedBox(height: 12),
                    _buildExpiryPicker(colors),

                    // ── Section: Notas ──
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Notas opcionales', icon: Icons.notes_rounded),
                    const SizedBox(height: 12),
                    _buildNotesField(colors),

                    // ── Error message ──
                    if (saveState.error != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error al guardar: ${saveState.error}',
                                style: TextStyle(color: colors.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Save button (SUB-04.3) ──
                    _buildSaveButton(colors, saveState.isSaving),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───── Field builders ─────

  Widget _buildNameField(ColorScheme colors) {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Nombre del producto',
        hintText: 'Ej: Leche entera, Arroz integral…',
        prefixIcon: Icon(Icons.label_outline_rounded),
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre es obligatorio';
        }
        if (value.trim().length < 2) {
          return 'El nombre debe tener al menos 2 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildBarcodeField(ColorScheme colors) {
    return TextFormField(
      controller: _barcodeController,
      readOnly: widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Código de barras',
        prefixIcon: const Icon(Icons.qr_code_rounded),
        suffixIcon: widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty
            ? Tooltip(
                message: 'Código escaneado',
                child: Icon(Icons.check_circle_rounded, color: colors.primary),
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryPicker(ColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ..._categories.map((Map<String, dynamic> cat) {
          final String label = cat['label'] as String;
          final IconData icon = cat['icon'] as IconData;
          final bool selected = _selectedCategory == label;

          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = selected ? null : label;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // "Create new" chip
        GestureDetector(
          onTap: () => _showCreateCategoryDialog(context, colors),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.secondary,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.add_rounded, size: 16, color: colors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Crear nueva',
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateCategoryDialog(BuildContext context, ColorScheme colors) async {
    final TextEditingController newCategoryController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Nueva Categoría',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: newCategoryController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Nombre de la categoría',
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: () {
                final String name = newCategoryController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _categories.add({
                      'label': name,
                      'icon': Icons.category_outlined, // Default icon for custom
                    });
                    _selectedCategory = name;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Unidades en inventario',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _QuantityButton(
                icon: Icons.remove_rounded,
                enabled: _quantity > 0,
                onTap: () => setState(() => _quantity -= 1),
                colors: colors,
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (Widget child, Animation<double> anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$_quantity',
                  key: ValueKey<int>(_quantity),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _QuantityButton(
                icon: Icons.add_rounded,
                enabled: true,
                onTap: () => setState(() => _quantity += 1),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildExpiryPicker(ColorScheme colors) {
    final bool hasDate = _expiryDate != null;
    final String dateText = hasDate
        ? DateFormat('d \'de\' MMMM, yyyy', 'es').format(_expiryDate!)
        : 'Sin fecha de vencimiento';

    return GestureDetector(
      onTap: () => _pickDate(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: hasDate
              ? colors.primaryContainer.withOpacity(0.5)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasDate ? colors.primary.withOpacity(0.4) : colors.outlineVariant,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.event_rounded,
              color: hasDate ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: hasDate ? colors.primary : colors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () => setState(() => _expiryDate = null),
                child: Icon(Icons.close_rounded, color: colors.primary, size: 20),
              )
            else
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(ColorScheme colors) {
    return TextFormField(
      controller: _notesController,
      minLines: 3,
      maxLines: 5,
      maxLength: 300,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        hintText: 'Ej: Comprado en oferta, revisar antes de usar…',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes_rounded),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colors, bool isSaving) {
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: colors.primary,
      ),
      onPressed: isSaving ? null : _save,
      child: isSaving
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Guardando…',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.check_rounded, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Guardar en inventario',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }

  // ───── Actions ─────

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 15),
      helpText: 'Selecciona la fecha de vencimiento',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );
    if (selectedDate != null) {
      setState(() => _expiryDate = selectedDate);
    }
  }

  // SUB-04.3 — Save use case & SUB-04.4 — Visual confirmation
  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String barcode = _barcodeController.text.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : _barcodeController.text.trim();

    final InventoryItem item = InventoryItem(
      id: 0,
      barcode: barcode,
      name: _nameController.text.trim(),
      brand: null,
      category: _selectedCategory,
      quantity: _quantity,
      expiryDate: _expiryDate,
      imageUrl: null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final bool success =
        await ref.read(_saveNotifierProvider.notifier).save(item);

    if (!mounted) return;

    if (success) {
      // SUB-04.4 — Snackbar de confirmación visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡${item.name} agregado al inventario!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

// ───────────────────────────────────────────────
// Reusable helper widgets
// ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: colors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? colors.primary : colors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colors.onPrimary : colors.onSurfaceVariant.withOpacity(0.4),
        ),
      ),
    );
  }
}
