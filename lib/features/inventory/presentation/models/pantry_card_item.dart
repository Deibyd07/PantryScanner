class PantryCardItem {
  const PantryCardItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.daysLeft,
    required this.progress,
    required this.imageUrl,
    required this.highlight,
  });

  final String name;
  final String category;
  final String quantity;
  final int daysLeft;
  final double progress;
  final bool highlight;
  final String imageUrl;
}
