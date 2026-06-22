import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'app_logo.dart';

/// Shown on web when API_BASE_URL was not baked in correctly at build time.
class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final message = AppConfig.configurationError ??
        'API_BASE_URL is not configured for production.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(height: 56),
                  const SizedBox(height: 24),
                  const Text(
                    'App configuration needed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Vercel → Settings → Environment Variables\n'
                    'API_BASE_URL = https://shopping-cart-backend-slwz.onrender.com/api\n\n'
                    'Do not use IMAGE_BASE_URL for API calls.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF6B7280),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
