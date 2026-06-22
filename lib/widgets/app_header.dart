import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api/api_client.dart';
import '../models/user.dart';
import '../providers/app_providers.dart';
import 'app_logo.dart';
import 'auth_dialog.dart';
import 'cart_badge_icon.dart';

/// Teal sticky header matching React `Header.jsx`.
class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refreshCount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (!auth.authenticated && _user != null) {
      _user = null;
    } else if (auth.authenticated && _user == null) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) return;
    try {
      final user = await context.read<ApiClient>().getCurrentUser();
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<CartProvider>().resetCount();
    if (mounted) {
      setState(() => _user = null);
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1024;

    return Material(
      color: const Color(0xFF0D9488),
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 64 : 16,
            vertical: 4,
          ),
          child: SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: const AppLogo(height: 40, compact: true),
                ),
                const Spacer(),
                if (wide) ...[
                  if (_user != null)
                    PopupMenuButton<String>(
                      offset: const Offset(0, 48),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            child: Text(
                              _user!.firstName.isNotEmpty
                                  ? _user!.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_user!.firstName} ${_user!.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.expand_more, color: Colors.white),
                        ],
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            context.go('/me');
                          case 'orders':
                            context.go('/orders');
                          case 'logout':
                            _logout();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Text(
                            '${_user!.firstName} ${_user!.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'profile',
                          child: Text('Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'orders',
                          child: Text('Order History'),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                    )
                  else
                    TextButton.icon(
                      onPressed: () => showAuthDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                      label: const Text(
                        'Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 24),
                  CartBadgeIcon(
                    onTap: () => context.push('/cart'),
                    iconColor: Colors.white,
                    badgeColor: const Color(0xFF14B8A6),
                  ),
                ] else
                  CartBadgeIcon(
                    onTap: () => context.push('/cart'),
                    iconColor: Colors.white,
                    badgeColor: const Color(0xFF14B8A6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
