abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message (statusCode: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}

class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized access'])
      : super(message, 401);
}
