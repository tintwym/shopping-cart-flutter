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
    this.showSaveButton = true,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool showSaveButton;

  static const _cardRadius = 20.0;
  static const _accent = Color(0xFFB8734A);
  static const _accentSoft = Color(0xFFF3E4D8);
  static const _cardSurface = Color(0xFFFAFAF8);
  static const _titleColor = Color(0xFF2D2A26);
  static const _muted = Color(0xFF9CA3AF);
  static const _bodyMuted = Color(0xFF6B7280);

  String? get _imageUrl {
    if (product.images.isEmpty) return null;
    return productImageUrl(product.images.first.path);
  }

  String get _stockLabel {
    if (product.deleted || product.stock <= 0) return 'SOLD OUT';
    if (product.stock <= 5) return 'LOW STOCK';
    return 'IN STOCK';
  }

  Color get _badgeBackground {
    if (product.deleted || product.stock <= 0) {
      return const Color(0xFFE5E7EB);
    }
    return _accentSoft;
  }

  Color get _badgeForeground {
    if (product.deleted || product.stock <= 0) {
      return const Color(0xFF6B7280);
    }
    return _accent;
  }

  String _formatPrice(num price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final isSaved = saved.isSaved(product.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImage(
                imageUrl: _imageUrl,
                showSaveButton: showSaveButton,
                isSaved: isSaved,
                onSave: () => saved.toggle(product.id),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PIXEL TECH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stockLabel == 'IN STOCK' ? 'ELECTRONICS' : _stockLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: _bodyMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE8E5E1)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _MetaItem(
                                icon: Icons.inventory_2_outlined,
                                label: '${product.stock}',
                              ),
                              const SizedBox(width: 12),
                              _MetaItem(
                                icon: Icons.sell_outlined,
                                label: 'S\$${_formatPrice(product.price)}',
                              ),
                              const SizedBox(width: 12),
                              _MetaItem(
                                icon: Icons.shopping_bag_outlined,
                                label: product.stock > 0 ? '1+' : '0',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _badgeBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _stockLabel == 'IN STOCK' ? 'NEW' : _stockLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: _badgeForeground,
                            ),
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
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.showSaveButton,
    required this.isSaved,
    required this.onSave,
  });

  final String? imageUrl;
  final bool showSaveButton;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(ProductCard._cardRadius),
      ),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) => const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Center(child: AppLogoPlaceholder(size: 48)),
                ),
              )
            else
              const ColoredBox(
                color: Color(0xFFF3F4F6),
                child: Center(child: AppLogoPlaceholder(size: 48)),
              ),
            Positioned(
              top: 12,
              left: 12,
              child: IgnorePointer(
                child: _CircleIconButton(
                  onPressed: () {},
                  icon: Icons.devices_outlined,
                  iconColor: const Color(0xFF0D9488),
                ),
              ),
            ),
            if (showSaveButton)
              Positioned(
                top: 12,
                right: 12,
                child: _CircleIconButton(
                  onPressed: onSave,
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  iconColor: isSaved
                      ? const Color(0xFF0D9488)
                      : const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ProductCard._muted),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ProductCard._muted,
          ),
        ),
      ],
    );
  }
}
