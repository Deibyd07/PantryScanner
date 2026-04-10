import 'package:drift/drift.dart';

import '../../domain/entities/inventory_item.dart';
import '../../../../core/database/app_database.dart';

extension ProductToInventoryItemMapper on Product {
  InventoryItem toEntity() {
    return InventoryItem(
      id: id,
      barcode: barcode,
      name: name,
      brand: brand,
      category: category,
      quantity: quantity,
      expiryDate: expiryDate,
      imageUrl: imageUrl,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

extension InventoryItemToCompanionMapper on InventoryItem {
  ProductsCompanion toCompanion() {
    return ProductsCompanion.insert(
      barcode: barcode,
      name: name,
      brand: Value(brand),
      category: Value(category),
      quantity: Value(quantity),
      expiryDate: Value(expiryDate),
      imageUrl: Value(imageUrl),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }
}
