class ProductImage {
  ProductImage({required this.id, required this.path, this.altText});

  final String id;
  final String path;
  final String? altText;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as String,
      path: json['path'] as String,
      altText: json['altText'] as String?,
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.deleted,
    this.images = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final int stock;
  final bool deleted;
  final List<ProductImage> images;
  final String? createdAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as num? ?? 0,
      stock: json['stock'] as int? ?? 0,
      deleted: json['deleted'] as bool? ??
          json['isDeleted'] as bool? ??
          false,
      createdAt: json['createdAt'] as String?,
      images: imagesJson
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
