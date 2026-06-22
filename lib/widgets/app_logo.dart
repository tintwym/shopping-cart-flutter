import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand logo used in headers, placeholders, and empty states.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 48,
    this.userVariant = false,
    this.compact = false,
  });

  final double height;
  final bool userVariant;

  /// Trims extra padding baked into the SVG — use in the nav bar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final asset = userVariant ? 'assets/user_logo.svg' : 'assets/logo.svg';
    final svg = SvgPicture.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
    );

    if (!compact) return svg;

    // logo.svg uses a square viewBox with generous margins around the mark.
    return SizedBox(
      height: height,
      width: height * 2.35,
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          widthFactor: 0.78,
          heightFactor: 0.78,
          child: Transform.scale(
            scale: 1.35,
            child: svg,
          ),
        ),
      ),
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
