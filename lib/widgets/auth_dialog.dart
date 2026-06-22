import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'app_logo.dart';

enum AuthDialogMode { login, register }

/// Opens login or register as a centered modal over the current page.
Future<bool?> showAuthDialog(
  BuildContext context, {
  AuthDialogMode mode = AuthDialogMode.login,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: AuthDialog(initialMode: mode),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key, this.initialMode = AuthDialogMode.login});

  final AuthDialogMode initialMode;

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late AuthDialogMode _mode;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  static final _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _switchMode(AuthDialogMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_mode == AuthDialogMode.login) {
        await context.read<AuthProvider>().login(
              _usernameController.text.trim(),
              _passwordController.text,
            );
      } else {
        await context.read<AuthProvider>().register(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
      await context.read<CartProvider>().refreshCount();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _mode == AuthDialogMode.login
              ? 'Username or password is incorrect.'
              : 'Registration failed. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == AuthDialogMode.login;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + viewInsets.bottom),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 720),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Center(child: AppLogo(height: 72, userVariant: true)),
                        const SizedBox(height: 20),
                        Text(
                          isLogin ? 'Welcome back' : 'Create your account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLogin
                              ? 'Sign in to shop, track orders, and manage your cart.'
                              : 'Join Pixel Tech to save your cart and order history.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!isLogin) ...[
                          _AuthField(
                            controller: _firstNameController,
                            label: 'First name',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _lastNameController,
                            label: 'Last name',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _AuthField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.alternate_email,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        if (!isLogin) ...[
                          _AuthField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || !v.contains('@') ? 'Invalid email' : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _AuthField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: isLogin
                              ? TextInputAction.done
                              : TextInputAction.next,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!isLogin && !_passwordPattern.hasMatch(v)) {
                              return 'Min 8 chars, 1 letter, 1 number, 1 special';
                            }
                            return null;
                          },
                          onFieldSubmitted: isLogin ? (_) => _submit() : null,
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _confirmController,
                            label: 'Confirm password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) => v != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isLogin ? 'Sign in' : 'Create account',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? 'Don\'t have an account? '
                                  : 'Already have an account? ',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => _switchMode(
                                        isLogin
                                            ? AuthDialogMode.register
                                            : AuthDialogMode.login,
                                      ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isLogin ? 'Create one' : 'Sign in',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }
}
