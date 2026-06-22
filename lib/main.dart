import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/cart_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/me_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/review_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/two_factor_screen.dart';
import 'widgets/app_shell.dart';
import 'widgets/config_error_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShoppingCartApp());
}

class ShoppingCartApp extends StatefulWidget {
  const ShoppingCartApp({super.key});

  @override
  State<ShoppingCartApp> createState() => _ShoppingCartAppState();
}

class _ShoppingCartAppState extends State<ShoppingCartApp> {
  late final ApiClient _apiClient;
  late final AuthProvider _authProvider;
  late final CartProvider _cartProvider;
  late final SavedProvider _savedProvider;
  late final GoRouter _router;
  final _appLinks = AppLinks();
  bool _cartCountLoaded = false;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authProvider = AuthProvider(_apiClient);
    _cartProvider = CartProvider(_apiClient);
    _savedProvider = SavedProvider();
    _router = _buildRouter();
    _authProvider.addListener(_onAuthChanged);
    if (!kIsWeb) {
      _listenForPaymentDeepLinks();
    }
  }

  void _onAuthChanged() {
    if (!_authProvider.loading &&
        _authProvider.authenticated &&
        !_cartCountLoaded) {
      _cartCountLoaded = true;
      _cartProvider.refreshCount();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _router.dispose();
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider,
      redirect: (context, state) {
        if (_authProvider.loading) return null;
        return null;
      },
      errorBuilder: (_, state) => NotFoundScreen(key: ValueKey(state.uri)),
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppLayout(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const ProductsScreen()),
            GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
            GoRoute(
              path: '/orders',
              builder: (_, _) => const OrderHistoryScreen(),
            ),
            GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
            GoRoute(path: '/me', builder: (_, _) => const MeScreen()),
            GoRoute(
              path: '/me/settings',
              builder: (_, _) => const ProfileSettingsScreen(),
            ),
            GoRoute(
              path: '/me/change-password',
              builder: (_, _) => const ChangePasswordScreen(),
            ),
            GoRoute(
              path: '/me/two-factor',
              builder: (_, _) => const TwoFactorScreen(),
            ),
            GoRoute(
              path: '/me/payment-methods',
              builder: (_, _) => const PaymentMethodsScreen(),
            ),
            GoRoute(
              path: '/me/admin/products',
              builder: (_, _) => const AdminProductsScreen(),
            ),
            GoRoute(
              path: '/profile',
              redirect: (_, _) => '/me',
            ),
            GoRoute(
              path: '/products/:id',
              builder: (context, state) => ProductDetailScreen(
                productId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/products/:productId/reviews/:orderItemId/create',
              builder: (context, state) => ReviewScreen(
                productId: state.pathParameters['productId']!,
                orderItemId: state.pathParameters['orderItemId']!,
              ),
            ),
            GoRoute(
              path: '/payment/success',
              builder: (context, state) => PaymentSuccessScreen(
                sessionId: state.uri.queryParameters['session_id'] ?? '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _listenForPaymentDeepLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handleDeepLink(initial);
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'payment' && uri.pathSegments.contains('success')) {
      final sessionId = uri.queryParameters['session_id'];
      if (sessionId != null && sessionId.isNotEmpty) {
        _router.go('/payment/success?session_id=$sessionId');
      }
    } else if (uri.host == 'cart') {
      _router.go('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isApiConfigured && kIsWeb) {
      final host = Uri.base.host;
      final isLocal = host == 'localhost' || host == '127.0.0.1';
      if (!isLocal) {
        return const MaterialApp(
          home: ConfigErrorScreen(),
        );
      }
    }

    if (_authProvider.loading) {
      return MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider.value(value: _savedProvider),
      ],
      child: MaterialApp.router(
        title: 'Pixel Tech',
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
