import 'package:flutter/material.dart';

/// Teal footer matching React `Footer.jsx`.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const _socialIcons = [
    Icons.facebook,
    Icons.camera_alt_outlined,
    Icons.close,
    Icons.code,
    Icons.play_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return ColoredBox(
      color: const Color(0xFF0D9488),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _socialIcons
                  .map(
                    (icon) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '© $year Pixel Tech, Inc. All rights reserved.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
