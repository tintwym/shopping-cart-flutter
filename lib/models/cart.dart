import 'product.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  final String id;
  final Product product;
  final int quantity;
  final num price;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 0,
      price: json['price'] as num? ?? 0,
    );
  }
}

class Cart {
  Cart({required this.id, required this.cartItems, this.totalPrice});

  final String id;
  final List<CartItem> cartItems;
  final num? totalPrice;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['cartItems'] as List<dynamic>? ?? [];
    return Cart(
      id: json['id'] as String? ?? '',
      totalPrice: json['totalPrice'] as num?,
      cartItems: itemsJson
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
