enum ProductStatus {
  normal,
  expiringSoon,
  expired,
  outOfStock,
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.createdAt,
    this.expiryDate,
    this.imageUrl,
    this.notes,
  });

  final int id;
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final int quantity;
  final DateTime? expiryDate;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;

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
