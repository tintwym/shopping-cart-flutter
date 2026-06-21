import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/product.dart';
import 'app_logo.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  String? get _imageUrl {
    if (product.images.isEmpty) return null;
    return '${AppConfig.imageBaseUrl}/${product.images.first.path}';
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = !product.deleted && product.stock > 0;

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
