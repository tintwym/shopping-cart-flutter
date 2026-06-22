import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../providers/app_providers.dart';
import '../../utils/product_image_url.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/auth_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Review> _reviews = [];
  bool _loading = true;
  bool _reviewsExpanded = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<ApiClient>();
      final results = await Future.wait([
        api.getProduct(widget.productId),
        api.getProductReviews(widget.productId),
      ]);
      if (mounted) {
        setState(() {
          _product = results[0] as Product;
          _reviews = results[1] as List<Review>;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      final loggedIn = await showAuthDialog(context);
      if (loggedIn != true || !mounted) return;
    }
    try {
      await context.read<ApiClient>().addToCart(_product!.id);
      await context.read<CartProvider>().refreshCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product to cart')),
        );
      }
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
    if (_product == null) {
      return const Center(child: Text('Product not found'));
    }

    return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _product!.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: productImageUrl(
                                          _product!.images.first.path)!,
                                      fit: BoxFit.contain,
                                    )
                                  : const ColoredBox(
                                      color: Color(0xFFF3F4F6),
                                      child: AppLogoPlaceholder(size: 72),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _SaveButton(productId: _product!.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _product!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'S\$${_product!.price}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_product!.stock} in stock',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _product!.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _product!.deleted || _product!.stock <= 0
                            ? null
                            : _addToCart,
                        child: const Text('Add to bag'),
                      ),
                      const SizedBox(height: 24),
                      ExpansionPanelList(
                        elevation: 0,
                        expandedHeaderPadding: EdgeInsets.zero,
                        expansionCallback: (_, isExpanded) {
                          setState(() => _reviewsExpanded = !isExpanded);
                        },
                        children: [
                          ExpansionPanel(
                            isExpanded: _reviewsExpanded,
                            headerBuilder: (_, _) => const ListTile(
                              title: Text(
                                'Reviews',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            body: _reviews.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      'No reviews available for this product.',
                                      style: TextStyle(color: Color(0xFF6B7280)),
                                    ),
                                  )
                                : Column(
                                    children: _reviews.map((review) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          [
                                            review.user?.firstName,
                                            review.user?.lastName,
                                          ].where((s) => s != null && s.isNotEmpty).join(' '),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: List.generate(5, (i) {
                                                return Icon(
                                                  i < review.rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 16,
                                                  color: Colors.amber,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(review.comment),
                                            if (review.createdAt != null)
                                              Text(
                                                _formatDate(review.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                      const LayoutScrollFooter(),
                    ],
                  ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final isSaved = saved.isSaved(productId);
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: () => saved.toggle(productId),
        icon: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? const Color(0xFF0D9488) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
