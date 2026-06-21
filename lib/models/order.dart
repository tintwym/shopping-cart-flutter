import 'product.dart';

class OrderItem {
  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  final String id;
  final Product product;
  final int quantity;
  final num price;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 0,
      price: json['price'] as num? ?? 0,
    );
  }
}

class Order {
  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.orderItems,
    this.createdAt,
  });

  final String id;
  final num totalPrice;
  final String status;
  final List<OrderItem> orderItems;
  final String? createdAt;

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['orderItems'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as String,
      totalPrice: json['totalPrice'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      orderItems: itemsJson
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
