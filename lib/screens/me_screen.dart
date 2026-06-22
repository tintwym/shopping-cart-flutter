import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/guest_auth_views.dart';
import '../../widgets/profile_menu.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await context.read<ApiClient>().getCurrentUser();
      if (mounted) setState(() => _user = user);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<CartProvider>().resetCount();
    if (mounted) {
      setState(() {
        _user = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.authenticated) {
      return GuestMeView(onSignedIn: _load);
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final initial = _user?.firstName.isNotEmpty == true
        ? _user!.firstName[0].toUpperCase()
        : '?';

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 16),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          _user?.email ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ProfileMenuSection(
          title: 'Account',
          children: [
            ProfileMenuTile(
              icon: Icons.person_outline,
              title: 'Profile settings',
              subtitle: 'Name, shipping address',
              onTap: () => context.push('/me/settings'),
            ),
            const Divider(height: 1, indent: 72),
            ProfileMenuTile(
              icon: Icons.lock_outline,
              title: 'Change password',
              onTap: () => context.push('/me/change-password'),
            ),
            const Divider(height: 1, indent: 72),
            ProfileMenuTile(
              icon: Icons.security,
              title: 'Two-factor authentication',
              subtitle: 'Extra sign-in security',
              onTap: () => context.push('/me/two-factor'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileMenuSection(
          title: 'Shopping',
          children: [
            ProfileMenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'Orders & history',
              subtitle: 'Past purchases & receipts',
              onTap: () => context.go('/orders'),
            ),
            const Divider(height: 1, indent: 72),
            ProfileMenuTile(
              icon: Icons.credit_card,
              title: 'Payment methods',
              subtitle: 'Stripe checkout & cards',
              onTap: () => context.push('/me/payment-methods'),
            ),
          ],
        ),
        if (_user?.isAdmin == true) ...[
          const SizedBox(height: 16),
          ProfileMenuSection(
            title: 'Admin',
            children: [
              ProfileMenuTile(
                icon: Icons.inventory_2_outlined,
                title: 'Manage products',
                subtitle: 'Add, upload images, remove items',
                onTap: () => context.push('/me/admin/products'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF111827),
            ),
            child: const Text('Log out'),
          ),
        ),
        const LayoutScrollFooter(),
      ],
    );
  }
}
