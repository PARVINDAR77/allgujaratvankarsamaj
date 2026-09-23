/// Centralized API error types. Repositories convert DioException into these.
/// UI layers consume ApiFailure — never raw DioException.
enum ApiFailureType {
  badRequest,        // 400
  unauthorized,      // 401
  forbidden,         // 403
  notFound,          // 404
  conflict,          // 409
  validationError,   // 422
  tooManyRequests,   // 429
  serverError,       // 500+
  networkTimeout,
  noConnection,
  unknown,
}

class ApiFailure {
  final ApiFailureType type;
  final String message;
  final int? statusCode;

  const ApiFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory ApiFailure.fromStatusCode(int statusCode, [String? message]) {
    final type = switch (statusCode) {
      400 => ApiFailureType.badRequest,
      401 => ApiFailureType.unauthorized,
      403 => ApiFailureType.forbidden,
      404 => ApiFailureType.notFound,
      409 => ApiFailureType.conflict,
      422 => ApiFailureType.validationError,
      429 => ApiFailureType.tooManyRequests,
      >= 500 => ApiFailureType.serverError,
      _ => ApiFailureType.unknown,
    };
    return ApiFailure(
      type: type,
      statusCode: statusCode,
      message: message ?? _defaultMessageFor(type),
    );
  }

  static String _defaultMessageFor(ApiFailureType type) {
    return switch (type) {
      ApiFailureType.unauthorized => 'Session expired. Please log in again.',
      ApiFailureType.forbidden => 'You do not have permission to perform this action.',
      ApiFailureType.notFound => 'The requested resource was not found.',
      ApiFailureType.serverError => 'A server error occurred. Please try again later.',
      ApiFailureType.networkTimeout => 'Connection timed out. Please check your internet.',
      ApiFailureType.noConnection => 'No internet connection. Please check your network.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }

  @override
  String toString() => 'ApiFailure($type, $statusCode): $message';
}
