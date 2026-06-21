import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../models/user.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _unit = TextEditingController();
  final _floor = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _zipCode = TextEditingController();

  User? _user;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _address1.dispose();
    _address2.dispose();
    _unit.dispose();
    _floor.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _zipCode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (!auth.authenticated) {
      final loggedIn = await context.push<bool>('/login');
      if (loggedIn != true || !mounted) {
        context.go('/');
        return;
      }
    }
    setState(() => _loading = true);
    try {
      final api = context.read<ApiClient>();
      final user = await api.getCurrentUser();
      final profile = await api.getProfile();
      if (mounted) {
        _user = user;
        _address1.text = profile.address1 ?? '';
        _address2.text = profile.address2 ?? '';
        _unit.text = profile.unit ?? '';
        _floor.text = profile.floor ?? '';
        _city.text = profile.city ?? '';
        _state.text = profile.state ?? '';
        _country.text = profile.country ?? '';
        _zipCode.text = profile.zipCode ?? '';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<ApiClient>().updateProfile(
            Profile(
              address1: _address1.text,
              address2: _address2.text,
              unit: _unit.text,
              floor: _floor.text,
              city: _city.text,
              state: _state.text,
              country: _country.text,
              zipCode: _zipCode.text,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<CartProvider>().resetCount();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('@${_user?.username ?? ''}'),
                          Text(_user?.email ?? ''),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shipping address',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address1,
                    decoration: const InputDecoration(labelText: 'Address line 1'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address2,
                    decoration: const InputDecoration(labelText: 'Address line 2'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _floor,
                          decoration: const InputDecoration(labelText: 'Floor'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _state,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _country,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _zipCode,
                    decoration: const InputDecoration(labelText: 'Zip code'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save address'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                  const LayoutScrollFooter(),
                ],
              ),
    );
  }
}
