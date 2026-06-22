import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_theme.dart';
import '../models/user.dart';
import '../providers/app_providers.dart';

/// Mobile bottom tabs: Home, Order, Saved, Me (avatar when signed in).
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  static const tabRoutes = ['/', '/orders', '/saved', '/me'];

  static bool isTabRoute(String location) => tabRoutes.contains(location);

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  User? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (!auth.authenticated) {
      if (_user != null) setState(() => _user = null);
    } else if (_user == null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await context.read<ApiClient>().getCurrentUser();
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  int _indexForLocation(String location) {
    final index = AppBottomNav.tabRoutes.indexOf(location);
    return index < 0 ? 0 : index;
  }

  Widget _meIcon({required bool selected}) {
    final auth = context.read<AuthProvider>();
    final borderColor = selected ? AppTheme.primary : Colors.grey.shade400;

    if (auth.authenticated && _user != null) {
      final initial = _user!.firstName.isNotEmpty
          ? _user!.firstName[0].toUpperCase()
          : '?';
      return CircleAvatar(
        radius: 13,
        backgroundColor: AppTheme.primary,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 13,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.person_outline,
        size: 16,
        color: borderColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _indexForLocation(location);

    return NavigationBar(
      height: 64,
      selectedIndex: selected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
      onDestinationSelected: (index) {
        final route = AppBottomNav.tabRoutes[index];
        if (route != location) context.go(route);
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Order',
        ),
        const NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          selectedIcon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: _meIcon(selected: false),
          selectedIcon: _meIcon(selected: true),
          label: 'Me',
        ),
      ],
    );
  }
}
