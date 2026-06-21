import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../core/api/api_client.dart';
import '../../models/order.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_shell.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      final loggedIn = await context.push<bool>('/login');
      if (loggedIn != true || !mounted) {
        context.go('/');
        return;
      }
    }
    setState(() => _loading = true);
    try {
      final orders = await context.read<ApiClient>().getOrderHistory();
      if (mounted) setState(() => _orders = orders);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? raw) {
    final parsed = DateTime.tryParse(raw ?? '');
    if (parsed == null) return '';
    return DateFormat.yMMMd().format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 320,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 48, color: Color(0xFF0D9488)),
                  const SizedBox(height: 16),
                  const Text('No orders found!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go shopping'),
                  ),
                ],
              ),
            ),
          ),
          const LayoutScrollFooter(),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _orders.length) {
            return const LayoutScrollFooter();
          }
          final order = _orders[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              if (order.createdAt != null)
                                Text(
                                  'Date: ${_formatDate(order.createdAt)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                              Text(
                                'Total: S\$${order.totalPrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(height: 24),
                              ...order.orderItems.map((item) {
                                final imageUrl = item.product.images.isNotEmpty
                                    ? '${AppConfig.imageBaseUrl}/${item.product.images.first.path}'
                                    : null;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: 72,
                                              height: 72,
                                              child: imageUrl != null
                                                  ? CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : const ColoredBox(
                                                      color: Color(0xFFF3F4F6),
                                                      child: Icon(
                                                          Icons.shopping_bag),
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
                                                Text(
                                                    'Qty: ${item.quantity}'),
                                                Text(
                                                    'S\$${item.product.price} each'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/products/${item.product.id}/reviews/${item.id}/create',
                                            ),
                                            child: const Text('Add review'),
                                          ),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/products/${item.product.id}',
                                            ),
                                            child: const Text('View product'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
        },
      ),
    );
  }
}