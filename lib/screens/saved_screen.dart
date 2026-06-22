import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_errors.dart';
import '../../models/product.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/auth_dialog.dart';
import '../../widgets/product_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  Set<String> _lastIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final saved = context.read<SavedProvider>();
      await saved.waitUntilReady();
      final ids = saved.ids;
      if (ids.isEmpty) {
        if (mounted) setState(() => _products = []);
        return;
      }
      final all = await context.read<ApiClient>().getProducts();
      if (mounted) {
        setState(() {
          _products = all.where((p) => ids.contains(p.id)).toList();
          _lastIds = ids;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    if (saved.ready && saved.ids != _lastIds && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved items yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark on a product to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved items are stored on this device only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Browse products'),
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
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: _products.length + 1,
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const LayoutScrollFooter();
          }
          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () => context.push('/products/${product.id}'),
            onAddToCart: () => _addToCart(product),
            showSaveButton: true,
          );
        },
      ),
    );
  }
}
