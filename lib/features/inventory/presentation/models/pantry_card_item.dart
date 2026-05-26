import '../../domain/entities/inventory_item.dart';

class PantryCardItem {
  const PantryCardItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.rawQuantity,
    required this.daysLeft,
    required this.progress,
    required this.imageUrl,
    required this.status,
  });

  final String name;
  final String category;
  final String quantity;
  final int rawQuantity;
  final int daysLeft;
  final double progress;
  final String imageUrl;
  final ProductStatus status;
}
