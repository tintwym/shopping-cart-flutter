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

  /// False on deployed web when no valid API URL is available.
  static bool get isApiConfigured {
    return isValidApiBaseUrl(apiBaseUrl);
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
  // Relative same-origin proxy (/api on Vercel) is valid on web.
  if (trimmed.startsWith('/')) {
    return trimmed == '/api' || trimmed.endsWith('/api');
  }
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return false;
  }
  if (!trimmed.endsWith('/api')) return false;
  return Uri.tryParse(trimmed)?.hasAuthority == true;
}

String? apiConfigurationError() {
  if (isValidApiBaseUrl(resolveApiBaseUrl())) return null;
  if (!kIsWeb) return null;
  final host = Uri.base.host;
  if (host == 'localhost' || host == '127.0.0.1') return null;

  if (_apiBaseUrlOverride.contains('IMAGE_BASE_URL')) {
    return 'API_BASE_URL on Vercel was set to IMAGE_BASE_URL by mistake. '
        'Remove or fix it, or redeploy — the app will use /api on your domain instead.';
  }
  return 'API is not configured. Set API_BASE_URL on Vercel to:\n'
      'https://shopping-cart-backend-slwz.onrender.com/api\n'
      'or ensure vercel.json proxies /api to your Render backend.';
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
    final host = Uri.base.host;
    final isLocal = host == 'localhost' || host == '127.0.0.1';
    if (!isLocal) {
      // Same-origin /api — proxied to Render via vercel.json (see DEPLOY.md).
      return '${Uri.base.origin}/api';
    }
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
