import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
// ignore: deprecated_member_use_from_same_package
import '../../../inventory/presentation/widgets/inventory_tokens.dart';
import '../../../../core/design/design_system.dart';

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
  int _existingId = 0; // If != 0, we are updating an existing product
  int _quantity = AppConstants.defaultQuantity; // default = 1
  DateTime? _expiryDate;
  String? _selectedCategory;
  String? _selectedImagePath; // New: local path of picked image

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
      // Try to auto-fill from local cache (works offline)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutofillFromCache(widget.initialBarcode!);
      });
    }

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  /// Looks up the local SQLite cache or inventory for [barcode] and auto-fills
  /// the form fields. If it's already in the inventory, we load its full state
  /// so saving will update it instead of duplicating.
  Future<void> _tryAutofillFromCache(String barcode) async {
    // 1. Try to find the existing full item in the inventory
    final InventoryItem? existingItem =
        await ref.read(itemByBarcodeProvider(barcode).future);
    
    if (existingItem != null && mounted) {
      setState(() {
        _existingId = existingItem.id;
        _nameController.text = existingItem.name;
        _selectedCategory = existingItem.category;
        _quantity = existingItem.quantity;
        _expiryDate = existingItem.expiryDate;
        _selectedImagePath = existingItem.imageUrl;
        if (existingItem.notes != null) {
          _notesController.text = existingItem.notes!;
        }
      });
      return;
    }

    // 2. If not in inventory, try to auto-fill metadata from the cache
    final Map<String, dynamic>? cached =
        await ref.read(productCacheProvider(barcode).future);
    if (cached == null || !mounted) return;
    setState(() {
      final String cachedName = cached['name'] as String? ?? '';
      if (cachedName.isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = cachedName;
      }
      final String? cachedCategory = cached['category'] as String?;
      if (cachedCategory != null && _selectedCategory == null) {
        _selectedCategory = cachedCategory;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  // ───── Image picker ─────
  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // close bottom sheet

    // Mobile & Web: use image_picker
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked != null) {
        setState(() => _selectedImagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir cámara/galería: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet(BuildContext context, ColorScheme colors) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Agregar foto del producto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (!kIsWeb) ...<Widget>[
                _ImageSourceTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Tomar foto',
                  subtitle: 'Abre la cámara del dispositivo',
                  colors: colors,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 10),
              ],
              _ImageSourceTile(
                icon: Icons.photo_library_rounded,
                label: kIsWeb ? 'Subir imagen' : 'Subir desde galería',
                subtitle: kIsWeb
                    ? 'Elige una imagen de tu computador'
                    : 'Elige una imagen guardada',
                colors: colors,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (kIsWeb) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'La cámara solo está disponible en la app móvil.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_selectedImagePath != null) ...<Widget>[
                const SizedBox(height: 10),
                _ImageSourceTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Quitar foto',
                  subtitle: 'Elimina la imagen seleccionada',
                  colors: colors,
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _selectedImagePath = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ───── Build ─────
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final _SaveState saveState = ref.watch(_saveNotifierProvider);
    final double topPad = MediaQuery.paddingOf(context).top;
    final double bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF7F1D1D),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // ── Gradient hero ──
              Container(
                height: 190 + topPad,
                width: double.infinity,
                padding: EdgeInsets.only(top: topPad),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFEF4444), Color(0xFF7F1D1D)],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: _buildHero(context),
                ),
              ),
              // ── White scrollable form ──
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPad + 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const _SectionHeader(title: 'Foto del producto', icon: Icons.photo_camera_outlined),
                          const SizedBox(height: 12),
                          _buildImagePicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          const _SectionHeader(title: 'Información básica', icon: Icons.info_outline_rounded),
                          const SizedBox(height: 12),
                          _buildNameField(colors),
                          const SizedBox(height: 12),
                          _buildBarcodeField(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          const _SectionHeader(title: 'Categoría', icon: Icons.category_outlined),
                          const SizedBox(height: 12),
                          _buildCategoryPicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          const _SectionHeader(title: 'Cantidad', icon: Icons.production_quantity_limits_rounded),
                          const SizedBox(height: 12),
                          _buildQuantitySelector(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          const _SectionHeader(title: 'Fecha de vencimiento', icon: Icons.event_rounded),
                          const SizedBox(height: 12),
                          _buildExpiryPicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          const _SectionHeader(title: 'Notas opcionales', icon: Icons.notes_rounded),
                          const SizedBox(height: 12),
                          _buildNotesField(colors),
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
                          _buildSaveButton(colors, saveState.isSaving),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFFC0392B), size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                'Agregar producto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Llena los datos y guarda en tu despensa',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───── Field builders ─────

  // ───── Image picker widget ─────
  Widget _buildImagePicker(ColorScheme colors) {
    final bool hasImage = _selectedImagePath != null;
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context, colors),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 180,
        decoration: BoxDecoration(
          color: hasImage ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? InventoryTokens.primary : InventoryTokens.outline,
            width: hasImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (kIsWeb)
                    Image.network(
                      _selectedImagePath!,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  // Edit overlay
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Cambiar foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: InventoryTokens.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: InventoryTokens.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Agregar foto del producto',
                    style: TextStyle(
                      color: InventoryTokens.textBody,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cámara · Galería · Opcional',
                    style: TextStyle(
                      color: InventoryTokens.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNameField(ColorScheme colors) {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: InventoryTokens.textBody),
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
      style: const TextStyle(color: InventoryTokens.textBody),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? InventoryTokens.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? InventoryTokens.primary : InventoryTokens.outline,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 15,
                    color: selected ? Colors.white : InventoryTokens.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : InventoryTokens.textBody,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryTokens.primary),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.add_rounded, size: 15, color: InventoryTokens.primary),
                SizedBox(width: 6),
                Text(
                  'Crear nueva',
                  style: TextStyle(
                    color: InventoryTokens.primary,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryTokens.outline),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDate ? InventoryTokens.primary : InventoryTokens.outline,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.event_rounded,
              color: hasDate ? InventoryTokens.primary : InventoryTokens.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: hasDate ? InventoryTokens.primary : InventoryTokens.textMuted,
                  fontSize: 14,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () => setState(() => _expiryDate = null),
                child: const Icon(Icons.close_rounded, color: InventoryTokens.primary, size: 20),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: InventoryTokens.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(ColorScheme colors) {
    return TextFormField(
      controller: _notesController,
      style: const TextStyle(color: InventoryTokens.textBody),
      minLines: 3,
      maxLines: 5,
      maxLength: 300,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        hintText: 'Ej: Comprado en oferta, revisar antes de usar…',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colors, bool isSaving) {
    return BrandGradientButton(
      label: 'Guardar en inventario',
      icon: Icons.check_rounded,
      isLoading: isSaving,
      onPressed: isSaving ? null : _save,
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
      id: _existingId,
      syncId: '', // Will be assigned by repository if new
      barcode: barcode,
      name: _nameController.text.trim(),
      brand: null,
      category: _selectedCategory,
      quantity: _quantity,
      expiryDate: _expiryDate,
      imageUrl: _selectedImagePath,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bool success =
        await ref.read(_saveNotifierProvider.notifier).save(item);

    if (!mounted) return;

    if (success) {
      AppHaptics.success();
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
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: InventoryTokens.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: InventoryTokens.textBody,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 20),
      color: const Color(0xFFF0F2F5),
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
          color: enabled ? colors.onPrimary : colors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// Image source tile for the bottom sheet
// ───────────────────────────────────────────────
class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final ColorScheme colors;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color tileColor = isDestructive ? colors.errorContainer : colors.surfaceContainerHighest;
    final Color iconColor = isDestructive ? colors.error : colors.primary;
    final Color labelColor = isDestructive ? colors.error : colors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
