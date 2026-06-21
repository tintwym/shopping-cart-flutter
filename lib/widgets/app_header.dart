import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api/api_client.dart';
import '../models/user.dart';
import '../providers/app_providers.dart';
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
      context.go('/login');
    }
  }

  void _openMobileMenu() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/logo.svg', height: 48),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _menuLink('Profile', () => context.go('/profile')),
                _menuLink('Products', () => context.go('/')),
                _menuLink('Cart', () => context.go('/cart')),
                _menuLink('Order History', () => context.go('/orders')),
                const Divider(height: 24),
                if (_user != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    },
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: const Color(0xFF111827),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: const Color(0xFF111827),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuLink(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
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
            vertical: 8,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  height: 72,
                ),
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
                          context.go('/profile');
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
                      const PopupMenuItem(value: 'profile', child: Text('Profile')),
                      const PopupMenuItem(
                        value: 'orders',
                        child: Text('Order History'),
                      ),
                      const PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.person_outline, color: Colors.white),
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
                IconButton(
                  onPressed: _openMobileMenu,
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
