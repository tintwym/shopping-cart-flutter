import '../config/app_config.dart';

/// Resolves a product image [path] from the API — full Cloudinary URL or legacy filename.
String? productImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  return '${AppConfig.imageBaseUrl}/$path';
}
