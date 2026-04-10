import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.initialBarcode});

  final String? initialBarcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  int _quantity = AppConstants.defaultQuantity;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del producto'),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(labelText: 'Codigo de barras'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Text('Cantidad'),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _quantity > 0 ? () => setState(() => _quantity -= 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity'),
                IconButton(
                  onPressed: () => setState(() => _quantity += 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.event),
              label: Text(
                _expiryDate == null
                    ? 'Seleccionar vencimiento'
                    : 'Vence: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar producto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate != null) {
      setState(() => _expiryDate = selectedDate);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final String barcode = _barcodeController.text.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : _barcodeController.text.trim();

    final InventoryItem item = InventoryItem(
      id: 0,
      barcode: barcode,
      name: _nameController.text.trim(),
      brand: null,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      quantity: _quantity,
      expiryDate: _expiryDate,
      imageUrl: null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ref.read(saveInventoryItemUseCaseProvider).call(item);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto guardado')),
    );

    Navigator.of(context).pop();
  }
}
