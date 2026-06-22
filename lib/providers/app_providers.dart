import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (_api.isAuthenticated) {
      try {
        await _api.getCurrentUser();
        _authenticated = true;
      } catch (_) {
        await _api.logout();
        _authenticated = false;
      }
    }
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
  int _refreshGeneration = 0;

  int get count => _count;

  Future<void> refreshCount() async {
    if (!_api.isAuthenticated) {
      _count = 0;
      notifyListeners();
      return;
    }
    final generation = ++_refreshGeneration;
    try {
      final next = await _api.getCartCount();
      if (generation == _refreshGeneration) {
        _count = next;
        notifyListeners();
      }
    } catch (_) {
      // Keep last known count on transient failures.
    }
  }

  void resetCount() {
    _count = 0;
    _refreshGeneration++;
    notifyListeners();
  }
}

class SavedProvider extends ChangeNotifier {
  static const _storageKey = 'saved_product_ids';

  final Set<String> _ids = {};
  bool _ready = false;

  bool get ready => _ready;
  Set<String> get ids => Set.unmodifiable(_ids);

  SavedProvider() {
    _load();
  }

  Future<void> waitUntilReady() async {
    while (!_ready) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  bool isSaved(String productId) => _ids.contains(productId);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_storageKey) ?? const []);
    _ready = true;
    notifyListeners();
  }

  Future<void> toggle(String productId) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _ids.toList());
  }
}
