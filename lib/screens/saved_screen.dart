import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../models/product.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/product_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final saved = context.read<SavedProvider>();
      if (!saved.ready) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      final ids = context.read<SavedProvider>().ids;
      if (ids.isEmpty) {
        if (mounted) setState(() => _products = []);
        return;
      }
      final all = await context.read<ApiClient>().getProducts();
      if (mounted) {
        setState(() {
          _products = all.where((p) => ids.contains(p.id)).toList();
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SavedProvider>();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
            onAddToCart: () {},
            showSaveButton: true,
          );
        },
      ),
    );
  }
}
