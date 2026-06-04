import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/category_l10n.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
// ignore: deprecated_member_use_from_same_package
import '../../../inventory/presentation/widgets/inventory_tokens.dart';
import '../../../product_lookup/domain/entities/product_info.dart';
import '../../../product_lookup/presentation/providers/product_lookup_providers.dart';
import '../../../../core/design/design_system.dart';

// ─────────────────────────────────────────
// Lookup status displayed under the barcode field while/after we query
// the cache + remote OpenFoodFacts API.
// ─────────────────────────────────────────
enum _LookupStatus { idle, loading, found, notFound }

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

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.initialBarcode});

  final String? initialBarcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int _existingId = 0;
  int _quantity = AppConstants.defaultQuantity;
  int _minStock = 1;
  DateTime? _expiryDate;
  String? _selectedCategory;
  String? _selectedImagePath;

  _LookupStatus _lookupStatus = _LookupStatus.idle;
  ProductLookupSource? _lookupSource;
  Timer? _lookupDebounce;
  String? _lastLookedUpBarcode;

  bool _isRemotePath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  // Canonical Spanish labels (kept in DB) + their icons.
  // Display label is translated via categoryLabel(context, canonical).
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

  late final AnimationController _headerAnim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      _barcodeController.text = widget.initialBarcode!;
      _lastLookedUpBarcode = widget.initialBarcode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveProduct(widget.initialBarcode!);
      });
    }

    _barcodeController.addListener(_onBarcodeChanged);

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  Future<void> _resolveProduct(String barcode) async {
    final InventoryItem? existingItem =
        await ref.read(itemByBarcodeProvider(barcode).future);

    if (existingItem != null && mounted) {
      setState(() {
        _existingId = existingItem.id;
        _nameController.text = existingItem.name;
        _selectedCategory = existingItem.category;
        _quantity = existingItem.quantity;
        _minStock = existingItem.minStock;
        _expiryDate = existingItem.expiryDate;
        _selectedImagePath = existingItem.imageUrl;
        if (existingItem.notes != null) {
          _notesController.text = existingItem.notes!;
        }
        _lookupStatus = _LookupStatus.idle;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _lookupStatus = _LookupStatus.loading);

    final ProductLookupResult result =
        await ref.read(productLookupProvider(barcode).future);

    if (!mounted) return;

    final AppLocalizations t = AppLocalizations.of(context);

    if (!result.hasProduct) {
      setState(() {
        _lookupStatus = _LookupStatus.notFound;
        _lookupSource = result.source;
      });
      AppHaptics.warning();
      _showLookupSnack(
        message: t.productLookupNotFoundSnack,
        background: const Color(0xFFB45309),
        icon: Icons.edit_note_rounded,
      );
      return;
    }

    final ProductInfo info = result.product!;
    setState(() {
      if (_nameController.text.isEmpty && info.name.isNotEmpty) {
        _nameController.text = info.name;
      }
      if (_selectedCategory == null && info.category != null) {
        _selectedCategory = info.category;
      }
      if (_selectedImagePath == null && (info.imageUrl?.isNotEmpty == true)) {
        _selectedImagePath = info.imageUrl;
      }
      _lookupStatus = _LookupStatus.found;
      _lookupSource = result.source;
    });
    AppHaptics.success();
    _showLookupSnack(
      message: t.productLookupFoundSnack,
      background: const Color(0xFF166534),
      icon: Icons.check_circle_rounded,
    );
  }

  void _showLookupSnack({
    required String message,
    required Color background,
    required IconData icon,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _barcodeController.removeListener(_onBarcodeChanged);
    _nameController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  void _onBarcodeChanged() {
    final String value = _barcodeController.text.trim();

    if (value.isEmpty) {
      _lookupDebounce?.cancel();
      _lastLookedUpBarcode = null;
      if (_lookupStatus != _LookupStatus.idle) {
        setState(() {
          _lookupStatus = _LookupStatus.idle;
          _lookupSource = null;
        });
      }
      return;
    }

    final bool isValidFormat = RegExp(r'^\d{12,13}$').hasMatch(value);
    if (!isValidFormat) return;
    if (value == _lastLookedUpBarcode) return;

    _lookupDebounce?.cancel();
    _lookupDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _lastLookedUpBarcode = value;
      _resolveProduct(value);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();

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
        final AppLocalizations t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.productFormImagePickerError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet(BuildContext context, ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
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
                t.productFormImagePickerTitle,
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
                  label: t.productFormTakePhoto,
                  subtitle: t.productFormTakePhotoSubtitle,
                  colors: colors,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 10),
              ],
              _ImageSourceTile(
                icon: Icons.photo_library_rounded,
                label: kIsWeb
                    ? t.productFormUploadImage
                    : t.productFormUploadFromGallery,
                subtitle: kIsWeb
                    ? t.productFormUploadFromComputerSubtitle
                    : t.productFormUploadFromGallerySubtitle,
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
                        t.productFormCameraWebNotice,
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
                  label: t.productFormRemovePhoto,
                  subtitle: t.productFormRemovePhotoSubtitle,
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppLocalizations t = AppLocalizations.of(context);
    final _SaveState saveState = ref.watch(_saveNotifierProvider);
    final double topPad = MediaQuery.paddingOf(context).top;
    final double bottomPad = MediaQuery.paddingOf(context).bottom;

    final double heroHeight = 190 + topPad;

    return Scaffold(
      backgroundColor: const Color(0xFF7F1D1D),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFEF4444), Color(0xFF7F1D1D)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: heroHeight,
            bottom: 0,
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
                          _SectionHeader(title: t.productFormSectionPhoto, icon: Icons.photo_camera_outlined),
                          const SizedBox(height: 12),
                          _buildImagePicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionBasic, icon: Icons.info_outline_rounded),
                          const SizedBox(height: 12),
                          if (_lookupStatus != _LookupStatus.idle) ...<Widget>[
                            _buildLookupStatusBanner(colors),
                            const SizedBox(height: 12),
                          ],
                          _buildNameField(colors),
                          const SizedBox(height: 12),
                          _buildBarcodeField(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionCategory, icon: Icons.category_outlined),
                          const SizedBox(height: 12),
                          _buildCategoryPicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionQuantity, icon: Icons.production_quantity_limits_rounded),
                          const SizedBox(height: 12),
                          _buildQuantitySelector(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionMinStock, icon: Icons.notification_important_outlined),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              t.productFormMinStockHint,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          _buildMinStockSelector(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionExpiry, icon: Icons.event_rounded),
                          const SizedBox(height: 12),
                          _buildExpiryPicker(colors),
                          const SizedBox(height: 28),
                          const _SectionDivider(),
                          _SectionHeader(title: t.productFormSectionNotes, icon: Icons.notes_rounded),
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
                                      t.productFormSaveError(saveState.error!),
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
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: heroHeight,
            child: FadeTransition(
              opacity: _fadeIn,
              child: _buildHero(context),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool isEditing = _existingId != 0;
    final String title = isEditing
        ? t.productFormHeroTitleEdit
        : t.productFormHeroTitleAdd;
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.productFormHeroSubtitle,
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

  Widget _buildImagePicker(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool hasImage = _selectedImagePath != null;
    return GestureDetector(
      onTap: () => _showImageSourceSheet(context, colors),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 180,
        decoration: BoxDecoration(
          color: hasImage
              ? const Color(0xFFF7F7F8)
              : Colors.white,
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
                  if (kIsWeb || _isRemotePath(_selectedImagePath!))
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        _selectedImagePath!,
                        fit: BoxFit.contain,
                        loadingBuilder: (BuildContext _, Widget child,
                            ImageChunkEvent? progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: InventoryTokens.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: InventoryTokens.outline.withValues(alpha: 0.2),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: InventoryTokens.textMuted,
                            size: 36,
                          ),
                        ),
                      ),
                    )
                  else
                    Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            t.productFormChangePhoto,
                            style: const TextStyle(
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
                  Text(
                    t.productFormImagePickerTitle,
                    style: const TextStyle(
                      color: InventoryTokens.textBody,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.productFormPhotoOptionsHint,
                    style: const TextStyle(
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
    final AppLocalizations t = AppLocalizations.of(context);
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: InventoryTokens.textBody),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: t.productFormNameLabel,
        hintText: t.productFormNameHint,
        prefixIcon: const Icon(Icons.label_outline_rounded),
      ),
      maxLength: 100,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return t.productFormNameRequired;
        }
        if (value.trim().length < 2) {
          return t.productFormNameMin;
        }
        return null;
      },
    );
  }

  Widget _buildBarcodeField(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    return TextFormField(
      controller: _barcodeController,
      style: const TextStyle(color: InventoryTokens.textBody),
      readOnly: widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: t.productFormBarcodeLabel,
        prefixIcon: const Icon(Icons.qr_code_rounded),
        suffixIcon: widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty
            ? Tooltip(
                message: t.productFormBarcodeScanned,
                child: Icon(Icons.check_circle_rounded, color: colors.primary),
              )
            : null,
      ),
    );
  }

  Widget _buildLookupStatusBanner(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    final IconData icon;
    final Color background;
    final Color foreground;
    final String title;
    final String subtitle;
    final Widget? leading;

    switch (_lookupStatus) {
      case _LookupStatus.loading:
        icon = Icons.travel_explore_rounded;
        background = colors.primaryContainer.withValues(alpha: 0.55);
        foreground = colors.onPrimaryContainer;
        title = t.productLookupLoadingTitle;
        subtitle = t.productLookupLoadingSubtitle;
        leading = SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(foreground),
          ),
        );
        break;
      case _LookupStatus.found:
        icon = _lookupSource == ProductLookupSource.cache
            ? Icons.bolt_rounded
            : Icons.check_circle_rounded;
        background = const Color(0xFFDCFCE7);
        foreground = const Color(0xFF166534);
        title = t.productLookupFoundTitle;
        subtitle = _lookupSource == ProductLookupSource.cache
            ? t.productLookupFoundCacheSubtitle
            : t.productLookupFoundApiSubtitle;
        leading = null;
        break;
      case _LookupStatus.notFound:
        icon = Icons.edit_note_rounded;
        background = const Color(0xFFFEF3C7);
        foreground = const Color(0xFF92400E);
        title = t.productLookupNotFoundTitle;
        subtitle = t.productLookupNotFoundSubtitle;
        leading = null;
        break;
      case _LookupStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          leading ?? Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.86),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ..._categories.map((Map<String, dynamic> cat) {
          final String canonical = cat['label'] as String;
          final IconData icon = cat['icon'] as IconData;
          final bool selected = _selectedCategory == canonical;
          final String displayLabel = categoryLabel(context, canonical);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = selected ? null : canonical;
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
                    displayLabel,
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
        GestureDetector(
          onTap: () => _showCreateCategoryDialog(context, colors),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryTokens.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.add_rounded, size: 15, color: InventoryTokens.primary),
                const SizedBox(width: 6),
                Text(
                  t.productFormCreateNewCategory,
                  style: const TextStyle(
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
    final AppLocalizations t = AppLocalizations.of(context);
    final TextEditingController newCategoryController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            t.productFormNewCategoryTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: newCategoryController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: t.productFormNewCategoryHint,
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
                t.commonCancel,
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
                      'icon': Icons.category_outlined,
                    });
                    _selectedCategory = name;
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(t.commonCreate),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
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
            t.productFormUnitsLabel,
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


  Widget _buildMinStockSelector(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InventoryTokens.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            t.productFormMinStockLabel,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _QuantityButton(
                icon: Icons.remove_rounded,
                enabled: _minStock > 1,
                onTap: () => setState(() => _minStock -= 1),
                colors: colors,
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (Widget child, Animation<double> anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$_minStock',
                  key: ValueKey<int>(_minStock),
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
                onTap: () => setState(() => _minStock += 1),
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryPicker(ColorScheme colors) {
    final AppLocalizations t = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    final bool hasDate = _expiryDate != null;
    final String dateText = hasDate
        ? DateFormat.yMMMMd(locale).format(_expiryDate!)
        : t.productFormNoExpiry;

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
    final AppLocalizations t = AppLocalizations.of(context);
    return TextFormField(
      controller: _notesController,
      style: const TextStyle(color: InventoryTokens.textBody),
      minLines: 3,
      maxLines: 5,
      maxLength: 300,
      decoration: InputDecoration(
        labelText: t.productFormNotesLabel,
        hintText: t.productFormNotesHint,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colors, bool isSaving) {
    final AppLocalizations t = AppLocalizations.of(context);
    return BrandGradientButton(
      label: t.productFormSave,
      icon: Icons.check_rounded,
      isLoading: isSaving,
      onPressed: isSaving ? null : _save,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final AppLocalizations t = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 15),
      helpText: t.productFormDatePickerHelp,
      confirmText: t.commonConfirm,
      cancelText: t.commonCancel,
    );
    if (selectedDate != null) {
      setState(() => _expiryDate = selectedDate);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    final String barcode = _barcodeController.text.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : _barcodeController.text.trim();

    final InventoryItem item = InventoryItem(
      id: _existingId,
      syncId: '',
      barcode: barcode,
      name: _nameController.text.trim(),
      brand: null,
      category: _selectedCategory,
      quantity: _quantity,
      minStock: _minStock,
      expiryDate: _expiryDate,
      imageUrl: _selectedImagePath,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bool wasEditing = _existingId != 0;
    final bool success =
        await ref.read(_saveNotifierProvider.notifier).save(item);

    if (!mounted) return;

    if (success) {
      AppHaptics.success();
      final AppLocalizations t = AppLocalizations.of(context);
      final String message = wasEditing
          ? t.productFormUpdatedSnack(item.name)
          : t.productFormSavedSnack(item.name);
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
                  message,
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
