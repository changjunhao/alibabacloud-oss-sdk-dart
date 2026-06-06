import 'dart:typed_data';
import 'error.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_extensions.dart';

/// Represents an error returned by the OSS server.
///
/// Contains the HTTP status code, response headers, parsed error fields,
/// and the original request target for diagnostics.
class ServerError implements SdkErrorType {
  /// The status code of the response
  final int statusCode;

  /// The headers of the response
  final Map<String, String> headers;

  /// Information for errors, extracted from response body
  final Map<String, String> errorFields;

  /// The method and URL of the request
  final String requestTarget;

  /// Snapshot of the raw response body
  final Uint8List? snapshot;

  /// The time when this error occurred
  final DateTime timestamp;

  /// The error code
  String get code {
    return errorFields['Code'] ?? 'BadErrorResponse';
  }

  /// The error message
  String get message {
    return errorFields['Message'] ?? '';
  }

  /// The id that is used to identify the request.
  String get requestId {
    if (errorFields.containsKey('RequestId')) {
      return errorFields['RequestId']!;
    }
    final headerValue = headers.getCaseInsensitive('x-oss-request-id');
    return headerValue ?? '';
  }

  /// A fine-grained error code. Each error cause corresponds to a unique error code.
  String get ec {
    if (errorFields.containsKey('EC')) {
      return errorFields['EC']!;
    }
    final headerValue = headers.getCaseInsensitive('x-oss-ec');
    return headerValue ?? '';
  }

  /// Gets the Error instance that caused the current exception.
  @override
  Exception? get innerError => null;

  ServerError({
    required this.statusCode,
    required this.headers,
    required this.errorFields,
    required this.requestTarget,
    this.snapshot,
  }) : timestamp = _toServerTime(headers);

  @override
  String get description {
    return '''
Error returned by Service.
Http Status Code: $statusCode
Error Code: $code
Request Id: $requestId
Message: $message
EC: $ec
Timestamp: $timestamp
Request Endpoint: $requestTarget
''';
  }

  @override
  String toString() => description;

  static DateTime _toServerTime(Map<String, String> headers) {
    final dateStr = headers.getCaseInsensitive('Date');
    if (dateStr != null) {
      final serverTime = DateFormatters.rfc5322DateTime.tryParse(dateStr);
      if (serverTime != null) {
        return serverTime;
      }
    }
    return DateTime.now();
  }
}
