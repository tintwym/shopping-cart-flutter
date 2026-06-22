import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/app_providers.dart';
import '../utils/product_image_url.dart';
import 'app_logo.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.showSaveButton = false,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool showSaveButton;

  String? get _imageUrl {
    if (product.images.isEmpty) return null;
    return productImageUrl(product.images.first.path);
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = !product.deleted && product.stock > 0;
    final saved = context.watch<SavedProvider>();
    final isSaved = saved.isSaved(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 288,
                width: double.infinity,
                child: InkWell(
                  onTap: onTap,
                  child: _imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _imageUrl!,
                          fit: BoxFit.contain,
                          placeholder: (_, _) => const ColoredBox(
                            color: Color(0xFFF3F4F6),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, _, _) => const ColoredBox(
                            color: Color(0xFFF3F4F6),
                            child: AppLogoPlaceholder(size: 56),
                          ),
                        )
                      : const ColoredBox(
                          color: Color(0xFFF3F4F6),
                          child: AppLogoPlaceholder(size: 56),
                        ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 144,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showSaveButton)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    onPressed: () => saved.toggle(product.id),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF6B7280),
                      size: 22,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                'S\$${product.price}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onTap,
          child: Text(
            product.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 160,
          child: Text(
            product.description,
            maxLines: 8,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('View Product'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: canAdd ? onAddToCart : null,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF111827),
              disabledBackgroundColor: const Color(0xFFF3F4F6),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Add to bag'),
          ),
        ),
      ],
    );
  }
}
