import 'dart:html' as html;

String ioApiBaseUrl() => 'http://localhost:8080/api';

String ioImageBaseUrl() => 'http://localhost:8080/images/products';

/// Set in `web/index.html` at Vercel build time (`vercel-build.sh`).
String? readWebMetaApiBaseUrl() {
  final meta = html.document.querySelector('meta[name="api-base-url"]');
  final content = meta?.getAttribute('content')?.trim();
  if (content == null || content.isEmpty) return null;
  return content;
}
