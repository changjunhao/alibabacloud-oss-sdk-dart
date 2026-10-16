import 'dart:typed_data';
import 'error.dart';

/// Client-side error thrown before or after sending an OSS request.
class ClientError implements SdkErrorType {
  /// The error code
  final String code;

  /// The detail error
  final String message;

  /// Gets the Error instance that caused the current exception.
  @override
  final Exception? innerError;

  /// Creates a client error with a code, message, and optional inner error.
  const ClientError({
    required this.code,
    required this.message,
    this.innerError,
  });

  @override
  /// Returns the `description` value.
  String get description {
    if (innerError != null) {
      return '$message\nCaused by:\n$innerError';
    } else {
      return message;
    }
  }

  @override
  String toString() => description;
}

/// Credentials error.
extension CredentialsErrors on ClientError {
  /// Creates an error for missing or empty credentials.
  static ClientError credentialsEmptyError({Exception? innerError}) {
    return ClientError(
      code: 'CredentialsError',
      message: 'Credentials is null or empty.',
      innerError: innerError,
    );
  }

  /// Creates an error for failures while fetching credentials.
  static ClientError credentialsFetchError({Exception? innerError}) {
    return ClientError(
      code: 'CredentialsFetchError',
      message: 'Fetch Credentials raised a error.',
      innerError: innerError,
    );
  }
}

/// Parameter error.
extension ParameterErrors on ClientError {
  /// Creates an error for an invalid parameter field.
  static ClientError paramInvalidError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Invalid field, $field.',
    );
  }

  /// Creates an error for a null parameter field.
  static ClientError paramNullError(String field) {
    return ClientError(code: 'ParameterError', message: 'Null field, $field.');
  }

  /// Creates an error for a null or empty parameter field.
  static ClientError paramNullOrEmptyError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Null or empty field, $field.',
    );
  }

  /// Creates an error for a missing required parameter field.
  static ClientError paramRequiredError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Missing required field, $field.',
    );
  }
}

/// Validation error.
extension ValidationErrors on ClientError {
  /// Creates a validation error for non-ASCII-digit account UID.
  static ClientError accountIdInvalidError(String value) {
    return ClientError(
      code: 'ValidationError',
      message: 'Account id is invalid, got $value.',
    );
  }

  /// Creates an error for an invalid bucket name.
  static ClientError bucketInvalidError(String value) {
    return ClientError(
      code: 'ValidationError',
      message: 'Bucket name is invalid, got $value.',
    );
  }

  /// Creates an error for an invalid object key.
  static ClientError objectInvalidError(String value) {
    return ClientError(
      code: 'ValidationError',
      message: 'Object name is invalid, got $value.',
    );
  }

  /// Creates an error for an invalid endpoint value.
  static ClientError endpointInvalidError() {
    return const ClientError(
      code: 'ValidationError',
      message: 'Endpoint is invalid.',
    );
  }
}

/// CRC check error.
extension CrcErrors on ClientError {
  /// Creates a CRC inconsistency error for mismatched client and server values.
  static ClientError inconsistentError(int clientCrc, int serverCrc) {
    return ClientError(
      code: 'InconsistentError',
      message: 'crc is inconsistent, client $clientCrc, server $serverCrc.',
    );
  }
}

/// Presign error.
extension PresignErrors on ClientError {
  /// Creates an error for a presign expiration outside the allowed range.
  static ClientError presignExpirationError(DateTime expiration) {
    return ClientError(
      code: 'PresignError',
      message:
          'Expires should be not greater than 604800(seven days), got $expiration.',
    );
  }
}

/// Serialization & Deserialization error.
extension SerdeErrors on ClientError {
  /// Creates an error for serialization failures.
  static ClientError serializationError({Exception? innerError}) {
    return ClientError(
      code: 'SerdeError',
      message: 'Serialization raised a error.',
      innerError: innerError,
    );
  }

  /// Creates an error for deserialization failures.
  static ClientError deserializationError({Exception? innerError}) {
    return ClientError(
      code: 'SerdeError',
      message: 'Deserialization raised a error.',
      innerError: innerError,
    );
  }

  /// Creates an error for response body parsing failures.
  static ClientError parseResponseBodyError({
    String? info,
    Uint8List? snapshot,
    Exception? innerError,
  }) {
    final bodyStr = snapshot != null ? String.fromCharCodes(snapshot) : '';
    final infoMessage = info ?? 'Parse response body fail.';
    final truncatedBody = bodyStr.length > 256
        ? bodyStr.substring(0, 256)
        : bodyStr;

    return ClientError(
      code: 'SerdeError',
      message: '$infoMessage part response body:\n$truncatedBody',
      innerError: innerError,
    );
  }
}

/// Operation Error
extension OperationErrors on ClientError {
  /// Creates an error for a failed named operation.
  static ClientError operationError(String name, Exception innerError) {
    return ClientError(
      code: 'OperationError',
      message: 'Operation $name raised a error.',
      innerError: innerError,
    );
  }
}

/// Remote signature Error
extension RemoteSignatureErrors on ClientError {
  /// Creates an error for missing required fields in a remote signature result.
  static ClientError signatureResultRequiredError(String field) {
    return ClientError(
      code: 'RemoteSignatureError',
      message: 'The signature result don\'t contain $field field.',
    );
  }

  /// Creates an error for remote signature invocation failures.
  static ClientError signatureCallError(Exception innerError) {
    return ClientError(
      code: 'RemoteSignatureError',
      message: 'Call delegate.signature field.',
      innerError: innerError,
    );
  }
}

/// Request & Response Error
extension RequestResponseErrors on ClientError {
  /// An error occurred while attempt to make a request to the service.
  static ClientError requestError(String detail, {Exception? innerError}) {
    return ClientError(
      code: 'RequestError',
      message: 'Request error: $detail',
      innerError: innerError,
    );
  }

  /// The request was sent, but the client failed to understand the response.
  /// The connection may have timed out. These errors can be retried for idempotent or safe operations
  static ClientError responseError(String detail, {Exception? innerError}) {
    return ClientError(
      code: 'ResponseError',
      message: 'Response error: $detail',
      innerError: innerError,
    );
  }
}

/// Cancellation error.
extension CancellationErrors on ClientError {
  /// The request was cancelled by the user via CancelToken.
  static ClientError requestCancelledError({
    String? reason,
    Exception? innerError,
  }) {
    return ClientError(
      code: 'RequestCancelled',
      message: 'HTTP request was cancelled: ${reason ?? 'cancelled'}',
      innerError: innerError,
    );
  }

  /// Checks if this error represents a cancelled request
  bool get isCancelled => code == 'RequestCancelled';
}
