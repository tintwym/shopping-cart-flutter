import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_errors.dart';
import '../../core/api/api_client.dart';
import '../../models/product.dart';
import '../../providers/app_providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/auth_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const _pageSize = 8;

  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      context.read<CartProvider>().refreshCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await context.read<ApiClient>().getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _filtered = products;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1;
    });
  }

  Future<void> _addToCart(Product product) async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      final loggedIn = await showAuthDialog(context);
      if (loggedIn != true || !mounted) return;
    }
    try {
      await context.read<ApiClient>().addToCart(product.id);
      await context.read<CartProvider>().refreshCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to cart successfully!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add product to cart.')),
        );
      }
    }
  }

  int get _totalPages =>
      (_filtered.length / _pageSize).ceil().clamp(1, 999999);

  List<Product> get _pageProducts {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _filtered.length) return [];
    final end = (start + _pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  List<int?> _pageNumbers() {
    if (_totalPages <= 7) {
      return List.generate(_totalPages, (i) => i + 1);
    }
    if (_currentPage <= 3) {
      return [1, 2, 3, null, _totalPages - 2, _totalPages - 1, _totalPages];
    }
    if (_currentPage < _totalPages - 2) {
      return [
        1,
        null,
        _currentPage - 1,
        _currentPage,
        _currentPage + 1,
        null,
        _totalPages,
      ];
    }
    return [
      1,
      null,
      _totalPages - 4,
      _totalPages - 3,
      _totalPages - 2,
      _totalPages - 1,
      _totalPages,
    ];
  }

  int _columnCount(double width) {
    if (width >= 1280) return 4;
    if (width >= 640) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnCount(constraints.maxWidth);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search Product . . .',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _searchController.text.isNotEmpty
                          ? Icons.clear
                          : Icons.search,
                      color: const Color(0xFF6B7280),
                    ),
                    onPressed: _searchController.text.isNotEmpty
                        ? () {
                            _searchController.clear();
                            _filterProducts();
                          }
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                ),
              ),
              const SizedBox(height: 64),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_filtered.isEmpty)
                SizedBox(
                  height: 480,
                  child: Center(
                    child: Text(
                      'No products found!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
              else ...[
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 32),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: columns > 1 ? 24 : 0,
                    mainAxisSpacing: 48,
                    mainAxisExtent: 700,
                  ),
                  itemCount: _pageProducts.length,
                  itemBuilder: (context, index) {
                    final product = _pageProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/products/${product.id}'),
                      onAddToCart: () => _addToCart(product),
                      showSaveButton: true,
                    );
                  },
                ),
                if (_totalPages > 1) ...[
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Prev'),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF374151),
                        ),
                      ),
                      ..._pageNumbers().map((page) {
                        if (page == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('...'),
                          );
                        }
                        final selected = page == _currentPage;
                        return TextButton(
                          onPressed: () => setState(() => _currentPage = page),
                          style: TextButton.styleFrom(
                            backgroundColor: selected
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFF3F4F6),
                            foregroundColor: selected
                                ? Colors.white
                                : const Color(0xFF374151),
                            minimumSize: const Size(44, 40),
                          ),
                          child: Text('$page'),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _currentPage < _totalPages
                            ? () => setState(() => _currentPage++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Next'),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ],
                const LayoutScrollFooter(),
              ],
            ],
          );
        },
      ),
    );
  }
}
