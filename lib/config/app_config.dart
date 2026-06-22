import 'package:flutter/foundation.dart';

import 'app_config_io.dart' if (dart.library.html) 'app_config_web.dart';

/// API and asset URLs. Override at build time with:
/// `--dart-define=API_BASE_URL=https://api.example.com/api`
/// `--dart-define=IMAGE_BASE_URL=https://api.example.com/images/products`
///
/// On web, [readWebMetaApiBaseUrl] (injected into `index.html` at Vercel build) wins
/// when the compile-time value is missing or invalid.
class AppConfig {
  static String get apiBaseUrl => resolveApiBaseUrl();
  static String get imageBaseUrl => resolveImageBaseUrl();

  /// False on deployed web when no valid API_BASE_URL was provided at build time.
  static bool get isApiConfigured {
    if (!kIsWeb) return isValidApiBaseUrl(apiBaseUrl);
    final host = Uri.base.host;
    final isLocal = host == 'localhost' || host == '127.0.0.1';
    if (isLocal) return true;
    return _hasValidProductionOverride();
  }

  static String? get configurationError => apiConfigurationError();

  static const double mobileMaxWidth = 430;
}

const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
const _imageBaseUrlOverride = String.fromEnvironment('IMAGE_BASE_URL');

const _placeholderMarkers = [
  'IMAGE_BASE_URL',
  'API_BASE_URL',
  '__API_BASE_URL__',
  r'${API_BASE_URL}',
  r'${IMAGE_BASE_URL}',
];

bool isValidApiBaseUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  for (final marker in _placeholderMarkers) {
    if (trimmed.contains(marker)) return false;
  }
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return false;
  }
  if (!trimmed.endsWith('/api')) return false;
  return Uri.tryParse(trimmed)?.hasAuthority == true;
}

String? apiConfigurationError() {
  if (_hasValidProductionOverride()) return null;
  if (!kIsWeb) return null;
  final host = Uri.base.host;
  if (host == 'localhost' || host == '127.0.0.1') return null;

  if (_apiBaseUrlOverride.contains('IMAGE_BASE_URL')) {
    return 'API_BASE_URL is set to IMAGE_BASE_URL on Vercel. '
        'Use your Render API URL instead, e.g.\n'
        'https://shopping-cart-backend-slwz.onrender.com/api';
  }
  return 'API_BASE_URL is missing or invalid. On Vercel set:\n'
      'API_BASE_URL=https://shopping-cart-backend-slwz.onrender.com/api\n'
      'then redeploy.';
}

bool _hasValidProductionOverride() {
  if (kIsWeb) {
    final meta = readWebMetaApiBaseUrl();
    if (meta != null && isValidApiBaseUrl(meta)) return true;
  }
  if (_apiBaseUrlOverride.isNotEmpty && isValidApiBaseUrl(_apiBaseUrlOverride)) {
    return true;
  }
  return false;
}

String resolveApiBaseUrl() {
  if (kIsWeb) {
    final meta = readWebMetaApiBaseUrl();
    if (meta != null && isValidApiBaseUrl(meta)) return meta;
  }

  if (_apiBaseUrlOverride.isNotEmpty && isValidApiBaseUrl(_apiBaseUrlOverride)) {
    return _apiBaseUrlOverride;
  }

  if (kIsWeb) {
    return 'http://localhost:8080/api';
  }
  return ioApiBaseUrl();
}

String resolveImageBaseUrl() {
  if (_imageBaseUrlOverride.isNotEmpty && !_imageBaseUrlOverride.contains('IMAGE_BASE_URL')) {
    return _imageBaseUrlOverride;
  }
  final api = resolveApiBaseUrl();
  if (isValidApiBaseUrl(api)) {
    return api.replaceFirst('/api', '/images/products');
  }
  if (kIsWeb) {
    return 'http://localhost:8080/images/products';
  }
  return ioImageBaseUrl();
}
