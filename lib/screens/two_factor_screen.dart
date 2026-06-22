import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/profile_menu.dart';

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  static const _prefKey = 'two_factor_enabled';

  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _enabled = prefs.getBool(_prefKey) ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable two-factor authentication'),
          content: const Text(
            'Authenticator app support is coming soon. You can turn on this preference now and we will notify you when it is available.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    if (mounted) setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: 'Two-factor authentication',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: SwitchListTile(
                    value: _enabled,
                    activeThumbColor: AppTheme.primary,
                    onChanged: _toggle,
                    title: const Text(
                      'Two-factor authentication',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _enabled
                          ? 'Preference saved. Full 2FA setup is coming soon.'
                          : 'Add an extra layer of security to your account.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    secondary: const Icon(Icons.security, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'When available, you will be able to use an authenticator app or SMS codes when signing in.',
                  style: TextStyle(color: Colors.grey.shade600, height: 1.45),
                ),
                const LayoutScrollFooter(),
              ],
            ),
    );
  }
}
