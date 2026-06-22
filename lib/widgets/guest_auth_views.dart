import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'auth_dialog.dart';

/// Shown on tab screens that need auth (orders, etc.).
class GuestSignInView extends StatelessWidget {
  const GuestSignInView({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.person_outline,
    this.onSignedIn,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onSignedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
              child: Icon(icon, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () async {
                final ok = await showAuthDialog(context);
                if (ok == true && context.mounted) onSignedIn?.call();
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text('Sign in'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Me tab when the user is not signed in.
class GuestMeView extends StatelessWidget {
  const GuestMeView({super.key, this.onSignedIn});

  final VoidCallback? onSignedIn;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome to Pixel Tech',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your profile, orders, and saved items.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () async {
            final ok = await showAuthDialog(context);
            if (ok == true) onSignedIn?.call();
          },
          icon: const Icon(Icons.login, size: 20),
          label: const Text('Sign in'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => showAuthDialog(
            context,
            mode: AuthDialogMode.register,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Create account'),
        ),
      ],
    );
  }
}
