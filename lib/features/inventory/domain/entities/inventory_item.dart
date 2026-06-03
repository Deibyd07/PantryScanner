enum ProductStatus {
  normal,
  expiringSoon,
  expired,
  outOfStock,
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.syncId,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.expiryDate,
    this.imageUrl,
    this.notes,
    this.minStock = 1,
  });

  final int id;
  final String syncId;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final int quantity;
  final DateTime? expiryDate;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int minStock;

  bool get isLowStock => quantity > 0 && quantity <= minStock;

  InventoryItem copyWith({
    int? id,
    String? syncId,
    String? barcode,
    String? name,
    String? brand,
    String? category,
    int? quantity,
    DateTime? expiryDate,
    String? imageUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? minStock,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
      minStock: minStock ?? this.minStock,
    );
  }

  ProductStatus get status {
    if (quantity <= 0) {
      return ProductStatus.outOfStock;
    }

    if (expiryDate == null) {
      return ProductStatus.normal;
    }

    final DateTime today = DateTime.now();
    final DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

    if (expiryDate!.isBefore(endOfToday)) {
      return ProductStatus.expired;
    }

    final int daysToExpiry = expiryDate!.difference(today).inDays;
    if (daysToExpiry <= 3) {
      return ProductStatus.expiringSoon;
    }

    return ProductStatus.normal;
  }
}
