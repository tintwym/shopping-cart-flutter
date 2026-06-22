import 'package:dio/dio.dart';

import '../../config/app_config.dart';

/// User-facing message for failed API calls (especially production misconfiguration).
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final uri = error.requestOptions.uri.toString();
    if (uri.contains('IMAGE_BASE_URL') || !AppConfig.isApiConfigured) {
      return 'API is misconfigured. Set API_BASE_URL on Vercel to your Render URL '
          '(https://…onrender.com/api) and redeploy.';
    }

    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (status == 403) {
      return 'You do not have permission for this action.';
    }
    if (status == 405) {
      return 'API URL is wrong (405). Set API_BASE_URL to your Render backend /api and redeploy.';
    }
    if (status != null && status >= 500) {
      return 'Server error ($status). Try again shortly.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the API. Check that API_BASE_URL points to your live backend.';
    }
    final data = error.response?.data;
    if (data is String && data.isNotEmpty && !data.contains('<html')) {
      return data;
    }
  }
  return 'Request failed. Please try again.';
}
