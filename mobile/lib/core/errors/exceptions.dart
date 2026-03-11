/// Custom exceptions for EduFlow
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  NetworkException(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// OTP verification exception
class OtpException extends AppException {
  final int? attemptsRemaining;

  OtpException(
    super.message, {
    super.code,
    super.originalError,
    this.attemptsRemaining,
  });

  @override
  String toString() => 'OtpException: $message (attempts: $attemptsRemaining)';
}

/// Database related exceptions
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'DatabaseException: $message';
}

/// Sync related exceptions
class SyncException extends AppException {
  final int? pendingCount;

  SyncException(
    super.message, {
    super.code,
    super.originalError,
    this.pendingCount,
  });

  @override
  String toString() => 'SyncException: $message (pending: $pendingCount)';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
    super.message, {
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Server exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    super.message, {
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}
