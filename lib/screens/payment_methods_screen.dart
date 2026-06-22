import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/profile_menu.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: 'Payment methods',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: AppTheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payments via Stripe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checkout uses Stripe secure payment. Card details are entered on Stripe and are not stored on Pixel Tech servers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Saved cards',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'No saved payment methods yet. Complete a purchase to pay with card, Apple Pay, or Google Pay through Stripe.',
            style: TextStyle(color: Colors.grey.shade600, height: 1.45),
          ),
          const LayoutScrollFooter(),
        ],
      ),
    );
  }
}
