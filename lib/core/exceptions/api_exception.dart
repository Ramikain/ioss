enum ApiErrorType {
  noConnection,
  networkError,
  serverError,
  clientError,
  unauthorized,
  parseError,
  timeout,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(
    this.message,
    this.type, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException: $message (Type: $type${statusCode != null ? ', Status: $statusCode' : ''})';
  }

  String get userFriendlyMessage {
    switch (type) {
      case ApiErrorType.noConnection:
        return 'No internet connection. Please check your network and try again.';
      case ApiErrorType.networkError:
        return 'Network error. Please check your connection and try again.';
      case ApiErrorType.serverError:
        return 'Server is temporarily unavailable. Please try again later.';
      case ApiErrorType.unauthorized:
        return 'Your session has expired. Please log in again.';
      case ApiErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ApiErrorType.parseError:
        return 'Unable to process server response. Please try again.';
      case ApiErrorType.clientError:
      case ApiErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  bool get isRetryable {
    switch (type) {
      case ApiErrorType.networkError:
      case ApiErrorType.serverError:
      case ApiErrorType.timeout:
        return true;
      case ApiErrorType.noConnection:
      case ApiErrorType.unauthorized:
      case ApiErrorType.clientError:
      case ApiErrorType.parseError:
      case ApiErrorType.unknown:
      default:
        return false;
    }
  }
}