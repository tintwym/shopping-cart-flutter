import 'package:dio/dio.dart';

/// User-facing message for failed API calls (especially production misconfiguration).
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final uri = error.requestOptions.uri.toString();
    if (uri.contains('IMAGE_BASE_URL') || uri.contains('API_BASE_URL')) {
      return 'API URL is misconfigured (IMAGE_BASE_URL placeholder). '
          'Redeploy with API_BASE_URL=https://your-backend.onrender.com/api '
          'or use the /api proxy in vercel.json.';
    }

    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (status == 403) {
      return 'You do not have permission for this action.';
    }
    if (status == 405) {
      return 'API request blocked (405). The app may be calling the wrong URL — '
          'redeploy after fixing API_BASE_URL on Vercel.';
    }
    if (status == 409) {
      return 'That username or email is already registered.';
    }
    if (status != null && status >= 500) {
      return 'Server error ($status). Try again shortly.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the API. Check that the backend is running on Render.';
    }
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is String && data.isNotEmpty && !data.contains('<html')) {
      return data;
    }
  }
  return 'Request failed. Please try again.';
}
