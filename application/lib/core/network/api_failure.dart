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
      ApiFailureType.unauthorized => 'Session expired. Please log in again. (સેશન પૂરું થયું છે. કૃપા કરીને ફરીથી લોગિન કરો.)',
      ApiFailureType.forbidden => 'You do not have permission to perform this action. (તમને આ કાર્ય કરવા માટે પરવાનગી નથી.)',
      ApiFailureType.notFound => 'The requested resource was not found. (માહિતી મળી નથી.)',
      ApiFailureType.serverError => 'A server error occurred. Please try again later. (સર્વર ભૂલ. કૃપા કરીને થોડા સમય પછી ફરી પ્રયાસ કરો.)',
      ApiFailureType.networkTimeout => 'Connection timed out. Please check your internet. (કનેક્શન સમય સમાપ્ત થયો. કૃપા કરીને તમારું ઇન્ટરનેટ તપાસો.)',
      ApiFailureType.noConnection => 'No internet connection. Please check your network. (ઇન્ટરનેટ કનેક્શન નથી. કૃપા કરીને તમારું નેટવર્ક તપાસો.)',
      _ => 'An unexpected error occurred. Please try again. (કોઈ અણધારી ભૂલ આવી. કૃપા કરીને ફરીથી પ્રયાસ કરો.)',
    };
  }

  @override
  String toString() => 'ApiFailure($type, $statusCode): $message';
}
