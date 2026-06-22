import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_errors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../widgets/profile_menu.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  bool _isAdmin = false;

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
      final user = await context.read<ApiClient>().getCurrentUser();
      if (!user.isAdmin) {
        if (mounted) {
          setState(() {
            _isAdmin = false;
            _error = 'Admin access required.';
          });
        }
        return;
      }
      _isAdmin = true;
      final products = await context.read<ApiClient>().getProducts();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showAddProduct() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const _AddProductDialog(),
    );
    if (created == true) _load();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${product.name}" from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<ApiClient>().deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed')),
        );
        _load();
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
    return SettingsPageShell(
      title: 'Manage products',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        if (!_isAdmin) ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => context.go('/me'),
                            child: const Text('Back to account'),
                          ),
                        ],
                      ],
                    ),
                  ),
                Expanded(
                  child: _isAdmin
                      ? RefreshIndicator(
                    onRefresh: _load,
                    child: _products.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('No products in catalog')),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _products.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Card(
                                child: ListTile(
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'S\$${product.price} · Stock ${product.stock}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteProduct(product),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (_isAdmin)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: _showAddProduct,
                    icon: const Icon(Icons.add),
                    label: const Text('Add product'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog();

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '10');
  final List<PlatformFile> _files = [];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() => _files.addAll(result.files));
    }
  }

  Future<void> _submit() async {
    final price = num.tryParse(_price.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    if (_name.text.trim().isEmpty || price == null || stock == null) {
      setState(() => _error = 'Name, price, and stock are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final images = <MultipartFile>[];
      for (final file in _files) {
        if (file.bytes != null) {
          images.add(MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ));
        }
      }
      await context.read<ApiClient>().createProduct(
            name: _name.text.trim(),
            description: _description.text.trim(),
            price: price,
            stock: stock,
            images: images,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add product'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price (SGD)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image_outlined),
                label: Text(_files.isEmpty
                    ? 'Add images'
                    : '${_files.length} image(s) selected'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
