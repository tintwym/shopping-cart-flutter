import 'package:flutter/foundation.dart';

import 'app_config_io.dart' if (dart.library.html) 'app_config_web.dart';

/// API and asset URLs. Override at build time with:
/// `--dart-define=API_BASE_URL=https://api.example.com/api`
/// `--dart-define=IMAGE_BASE_URL=https://api.example.com/images/products`
class AppConfig {
  static String get apiBaseUrl => resolveApiBaseUrl();
  static String get imageBaseUrl => resolveImageBaseUrl();

  static const double mobileMaxWidth = 430;
}

const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
const _imageBaseUrlOverride = String.fromEnvironment('IMAGE_BASE_URL');

String resolveApiBaseUrl() {
  if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
  if (kIsWeb) {
    return 'http://localhost:8080/api';
  }
  return ioApiBaseUrl();
}

String resolveImageBaseUrl() {
  if (_imageBaseUrlOverride.isNotEmpty) return _imageBaseUrlOverride;
  if (_apiBaseUrlOverride.isNotEmpty) {
    return _apiBaseUrlOverride.replaceFirst('/api', '/images/products');
  }
  if (kIsWeb) {
    return 'http://localhost:8080/images/products';
  }
  return ioImageBaseUrl();
}
