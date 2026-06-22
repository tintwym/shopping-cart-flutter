import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../models/cart.dart';
import '../../providers/app_providers.dart';
import '../../utils/product_image_url.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/auth_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? _cart;
  bool _loading = true;
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      final loggedIn = await showAuthDialog(context);
      if (loggedIn != true || !mounted) {
        context.go('/');
        return;
      }
    }
    setState(() => _loading = true);
    try {
      final cart = await context.read<ApiClient>().getCart();
      if (mounted) setState(() => _cart = cart);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      await context.read<ApiClient>().removeFromCart(item.product.id);
    } else {
      await context.read<ApiClient>().updateCartItem(item.product.id, newQty);
    }
    await context.read<CartProvider>().refreshCount();
    await _load();
  }

  Future<void> _removeItem(CartItem item) async {
    await context.read<ApiClient>().removeFromCart(item.product.id);
    await context.read<CartProvider>().refreshCount();
    await _load();
  }

  Future<void> _checkout() async {
    final allItems = _cart?.cartItems ?? [];
    final deletedNames = allItems
        .where((item) => item.product.deleted)
        .map((item) => item.product.name)
        .toList();
    final validItems =
        allItems.where((item) => !item.product.deleted).toList();

    if (validItems.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Oops . . .'),
          content: Text(
            deletedNames.isEmpty
                ? 'Your cart is empty.'
                : 'Your cart contains deleted products: ${deletedNames.join(', ')} which cannot be checked out.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    if (deletedNames.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted products will be skipped: ${deletedNames.join(', ')}',
          ),
        ),
      );
    }

    setState(() => _checkingOut = true);
    try {
      final session = await context.read<ApiClient>().checkout();
      final checkoutUrl = session.checkoutUrl;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('Stripe checkout URL missing from server');
      }
      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Stripe checkout')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  num get _total {
    final items = _cart?.cartItems ?? [];
    return items
        .where((i) => !i.product.deleted)
        .fold<num>(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart?.cartItems ?? [];

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
              children: [
                Expanded(
                  child: items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [
                            SizedBox(
                              height: 240,
                              child: Center(child: Text('Your cart is empty')),
                            ),
                            LayoutScrollFooter(),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length + 1,
                          separatorBuilder: (context, index) {
                            if (index >= items.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return const SizedBox(height: 12);
                          },
                          itemBuilder: (context, index) {
                            if (index == items.length) {
                              return const LayoutScrollFooter();
                            }
                            final item = items[index];
                            final imageUrl = item.product.images.isNotEmpty
                                ? productImageUrl(
                                    item.product.images.first.path)
                                : null;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 72,
                                        height: 72,
                                        child: imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                              )
                                            : const ColoredBox(
                                                color: Color(0xFFF3F4F6),
                                                child: AppLogoPlaceholder(size: 40),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (item.product.deleted)
                                            const Text(
                                              'Unavailable',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          Text('S\$${item.product.price}'),
                                          Row(
                                            children: [
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onPressed: item.product.deleted
                                                    ? null
                                                    : () => _updateQuantity(
                                                        item,
                                                        -1,
                                                      ),
                                                icon: const Icon(Icons.remove),
                                              ),
                                              Text('${item.quantity}'),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onPressed: item.product.deleted
                                                    ? null
                                                    : () => _updateQuantity(
                                                        item,
                                                        1,
                                                      ),
                                                icon: const Icon(Icons.add),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () =>
                                                    _removeItem(item),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'S\$${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _checkingOut || items.isEmpty
                            ? null
                            : _checkout,
                        child: _checkingOut
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Checkout with Stripe'),
                      ),
                    ],
                  ),
                ),
              ],
            );
  }
}