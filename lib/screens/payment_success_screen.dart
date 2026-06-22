import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_shell.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _confirm();
  }

  Future<void> _confirm() async {
    if (widget.sessionId.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'Missing payment session. Return from Stripe checkout to confirm your order.';
          _loading = false;
        });
      }
      return;
    }
    try {
      await context.read<ApiClient>().confirmCheckout(widget.sessionId);
      if (!mounted) return;
      context.read<CartProvider>().resetCount();
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/orders');
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not confirm payment. Please contact support.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(height: 72),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFD1FAE5),
                child: Icon(
                  _error == null ? Icons.check : Icons.error_outline,
                  color: _error == null
                      ? const Color(0xFF059669)
                      : Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _loading
                    ? 'Confirming payment…'
                    : _error ?? 'Payment successful',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (!_loading && _error == null)
                const Text(
                  'Thank you for your purchase. Redirecting to your orders…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 32),
              if (!_loading)
                ElevatedButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View order history'),
                ),
              const LayoutScrollFooter(),
            ],
          ),
        ),
    );
  }
}
