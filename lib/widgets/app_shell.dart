import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_footer.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';

/// Main layout — mirrors React `Layout` (Header + scrollable page body).
/// Footer is appended inside each screen's scroll content, like React.
class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.child});

  final Widget child;

  static const _wideBreakpoint = 1024.0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final location = GoRouterState.of(context).matchedLocation;
    final showTabs = !wide && AppBottomNav.isTabRoute(location);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: showTabs ? const AppBottomNav() : null,
    );
  }
}

/// Teal footer placed at the end of page scroll content.
class LayoutScrollFooter extends StatelessWidget {
  const LayoutScrollFooter({super.key});

  @override
  Widget build(BuildContext context) => const AppFooter();
}
