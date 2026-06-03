class ProductInfo {
  const ProductInfo({
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
  });

  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;

  ProductInfo copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
  }) {
    return ProductInfo(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
