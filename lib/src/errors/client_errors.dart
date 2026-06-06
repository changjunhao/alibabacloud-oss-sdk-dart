import 'dart:typed_data';
import 'error.dart';

class ClientError implements SdkErrorType {
  /// The error code
  final String code;

  /// The detail error
  final String message;

  /// Gets the Error instance that caused the current exception.
  @override
  final Exception? innerError;

  const ClientError({
    required this.code,
    required this.message,
    this.innerError,
  });

  @override
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
  static ClientError credentialsEmptyError({Exception? innerError}) {
    return ClientError(
      code: 'CredentialsError',
      message: 'Credentials is null or empty.',
      innerError: innerError,
    );
  }

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
  static ClientError paramInvalidError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Invalid field, $field.',
    );
  }

  static ClientError paramNullError(String field) {
    return ClientError(code: 'ParameterError', message: 'Null field, $field.');
  }

  static ClientError paramNullOrEmptyError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Null or empty field, $field.',
    );
  }

  static ClientError paramRequiredError(String field) {
    return ClientError(
      code: 'ParameterError',
      message: 'Missing required field, $field.',
    );
  }
}

/// Validation error.
extension ValidationErrors on ClientError {
  static ClientError bucketInvalidError(String value) {
    return ClientError(
      code: 'ValidationError',
      message: 'Bucket name is invalid, got $value.',
    );
  }

  static ClientError objectInvalidError(String value) {
    return ClientError(
      code: 'ValidationError',
      message: 'Object name is invalid, got $value.',
    );
  }

  static ClientError endpointInvalidError() {
    return const ClientError(
      code: 'ValidationError',
      message: 'Endpoint is invalid.',
    );
  }
}

/// CRC check error.
extension CrcErrors on ClientError {
  static ClientError inconsistentError(int clientCrc, int serverCrc) {
    return ClientError(
      code: 'InconsistentError',
      message: 'crc is inconsistent, client $clientCrc, server $serverCrc.',
    );
  }
}

/// Presign error.
extension PresignErrors on ClientError {
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
  static ClientError serializationError({Exception? innerError}) {
    return ClientError(
      code: 'SerdeError',
      message: 'Serialization raised a error.',
      innerError: innerError,
    );
  }

  static ClientError deserializationError({Exception? innerError}) {
    return ClientError(
      code: 'SerdeError',
      message: 'Deserialization raised a error.',
      innerError: innerError,
    );
  }

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
  static ClientError signatureResultRequiredError(String field) {
    return ClientError(
      code: 'RemoteSignatureError',
      message: 'The signature result don\'t contain $field field.',
    );
  }

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
