import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_logo.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(height: 80),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
