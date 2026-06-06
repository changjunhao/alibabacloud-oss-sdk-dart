import 'error_retryable.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/server_error.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

/// Service error retryable implementation.
class ServiceErrorRetryable implements ErrorRetryable {
  /// Creates a ServiceErrorRetryable instance.
  ServiceErrorRetryable();

  /// The `statusCodes` value.
  static const List<int> statusCodes = [401, 408, 429];

  /// The `errorCodes` value.
  static const List<String> errorCodes = ['RequestTimeTooSkewed', 'BadRequest'];

  /// The `errorMessages` value.
  static const List<String> errorMessages = [
    'Invalid signing date in Authorization header.',
  ];

  @override
  /// Returns the `isErrorRetryable` result.
  bool isErrorRetryable(Exception error) {
    if (error is ServerError) {
      // Check status codes
      if (statusCodes.contains(error.statusCode)) {
        return true;
      }

      // Check for 5xx server errors
      if (error.statusCode >= 500) {
        return true;
      }

      // Check error codes
      if (errorCodes.contains(error.code)) {
        return true;
      }

      // Check error messages
      if (errorMessages.contains(error.message)) {
        return true;
      }
    }

    return false;
  }
}

/// Client error retryable implementation.
class ClientErrorRetryable implements ErrorRetryable {
  /// Client error codes that are considered retryable.
  static const List<String> errorCodes = [
    'CredentialsFetchError',
    'InconsistentError',
    'SerdeError',
    'RemoteSignatureError',
    'ResponseError',
  ];

  /// Creates a client error retryability evaluator.
  const ClientErrorRetryable();

  @override
  /// Returns the `isErrorRetryable` result.
  bool isErrorRetryable(Exception error) {
    if (error is ClientError) {
      if (errorCodes.contains(error.code)) {
        return true;
      }
    }

    return false;
  }
}
