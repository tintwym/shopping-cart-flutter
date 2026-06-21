import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand logo used in headers, placeholders, and empty states.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 48,
    this.userVariant = false,
  });

  final double height;
  final bool userVariant;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      userVariant ? 'assets/user_logo.svg' : 'assets/logo.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

/// Square app mark for image placeholders (products, cart thumbnails).
class AppLogoPlaceholder extends StatelessWidget {
  const AppLogoPlaceholder({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.35,
        child: Image.asset(
          'assets/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
