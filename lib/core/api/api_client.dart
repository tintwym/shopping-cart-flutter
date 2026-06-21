import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../models/cart.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../models/user.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final authHeader = response.headers.value('authorization');
          if (authHeader != null && authHeader.startsWith('Bearer ')) {
            final newToken = authHeader.substring(7);
            await setToken(newToken);
          }
          handler.next(response);
        },
      ),
    );
  }

  late final Dio _dio;
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', token);
    }
  }

  Future<void> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/users/login',
      data: {'username': username, 'password': password},
    );
    final token = response.data?['token'] as String?;
    if (token == null) {
      throw Exception('Login failed');
    }
    await setToken(token);
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/users/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      },
    );
    final token = response.data?['token'] as String?;
    if (token == null) {
      throw Exception('Registration failed');
    }
    await setToken(token);
  }

  Future<void> logout() => setToken(null);

  Future<User> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/token');
    return User.fromJson(response.data!);
  }

  Future<List<Product>> getProducts() async {
    final response = await _dio.get<List<dynamic>>('/products/index');
    final products = response.data!
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    products.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return products;
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/show/$id');
    return Product.fromJson(response.data!);
  }

  Future<int> getCartCount() async {
    final response = await _dio.get<Map<String, dynamic>>('/carts/count');
    return response.data?['count'] as int? ?? 0;
  }

  Future<Cart> getCart() async {
    final response = await _dio.get<Map<String, dynamic>>('/carts/show');
    return Cart.fromJson(response.data!);
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    await _dio.post<void>(
      '/carts/store',
      queryParameters: {'productId': productId, 'quantity': quantity},
    );
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    await _dio.put<void>(
      '/carts/update',
      queryParameters: {'productId': productId, 'quantity': quantity},
    );
  }

  Future<void> removeFromCart(String productId) async {
    await _dio.delete<void>(
      '/carts/delete',
      queryParameters: {'productId': productId},
    );
  }

  Future<CheckoutSession> checkout() async {
    final response = await _dio.post<Map<String, dynamic>>('/checkout');
    final data = response.data!;
    return CheckoutSession(
      sessionId: data['sessionId'] as String,
      checkoutUrl: data['checkoutUrl'] as String?,
    );
  }

  Future<void> confirmCheckout(String sessionId) async {
    await _dio.post<void>(
      '/checkout/confirm',
      queryParameters: {'sessionId': sessionId},
    );
  }

  Future<List<Order>> getOrderHistory() async {
    final response = await _dio.get<List<dynamic>>('/orders/history');
    final orders = response.data!
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
    orders.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return orders;
  }

  Future<Profile> getProfile() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/users/profiles/show');
    return Profile.fromJson(response.data!);
  }

  Future<void> updateProfile(Profile profile) async {
    await _dio.post<void>(
      '/users/profiles/update',
      data: profile.toJson(),
    );
  }

  Future<List<Review>> getProductReviews(String productId) async {
    final response =
        await _dio.get<List<dynamic>>('/reviews/product/$productId');
    return response.data!
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitReview({
    required String productId,
    required String orderItemId,
    required int rating,
    required String comment,
  }) async {
    await _dio.post<void>(
      '/reviews/store',
      data: {
        'productId': productId,
        'orderItemId': orderItemId,
        'rating': rating,
        'comment': comment,
      },
    );
  }
}

class CheckoutSession {
  CheckoutSession({required this.sessionId, this.checkoutUrl});

  final String sessionId;
  final String? checkoutUrl;
}
