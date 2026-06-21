import 'package:flutter/material.dart';

import '../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api) {
    _init();
  }

  final ApiClient _api;
  bool _loading = true;
  bool _authenticated = false;

  bool get loading => _loading;
  bool get authenticated => _authenticated;

  Future<void> _init() async {
    await _api.loadToken();
    _authenticated = _api.isAuthenticated;
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    await _api.login(username, password);
    _authenticated = true;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    await _api.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
    );
    _authenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _authenticated = false;
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  CartProvider(this._api);

  final ApiClient _api;
  int _count = 0;

  int get count => _count;

  Future<void> refreshCount() async {
    if (!_api.isAuthenticated) {
      _count = 0;
      notifyListeners();
      return;
    }
    _count = await _api.getCartCount();
    notifyListeners();
  }

  void resetCount() {
    _count = 0;
    notifyListeners();
  }
}
