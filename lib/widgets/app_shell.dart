import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_header.dart';

/// Main layout — mirrors React `Layout` (Header + scrollable page body).
/// Footer is appended inside each screen's scroll content, like React.
class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Teal footer placed at the end of page scroll content.
class LayoutScrollFooter extends StatelessWidget {
  const LayoutScrollFooter({super.key});

  @override
  Widget build(BuildContext context) => const AppFooter();
}
