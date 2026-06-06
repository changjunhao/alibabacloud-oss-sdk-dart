import 'attributes.dart';
import 'byte_stream.dart';

/// Operation input parameters for OSS requests
class OperationInput {
  /// The name of the operation
  String operationName;

  /// HTTP method for the request
  String method;

  /// HTTP headers for the request
  Map<String, String> headers;

  /// Query parameters for the request
  Map<String, String?> parameters;

  /// Request body as ByteStream
  ByteStream? body;

  /// OSS bucket name
  String? bucket;

  /// OSS object key
  String? key;

  /// Additional metadata attributes
  Attributes metadata;

  /// Creates a new OperationInput instance
  OperationInput({
    this.operationName = '',
    this.method = '',
    Map<String, String>? headers,
    Map<String, String?>? parameters,
    this.body,
    this.bucket,
    this.key,
  }) : headers = headers ?? <String, String>{},
       parameters = parameters ?? <String, String?>{},
       metadata = Attributes();

  /// Creates a copy of this OperationInput with optional parameter overrides
  OperationInput copyWith({
    String? operationName,
    String? method,
    Map<String, String>? headers,
    Map<String, String?>? parameters,
    ByteStream? body,
    String? bucket,
    String? key,
    Attributes? metadata,
  }) {
    return OperationInput(
      operationName: operationName ?? this.operationName,
      method: method ?? this.method,
      headers: headers ?? Map<String, String>.from(this.headers),
      parameters: parameters ?? Map<String, String?>.from(this.parameters),
      body: body ?? this.body,
      bucket: bucket ?? this.bucket,
      key: key ?? this.key,
    )..metadata = metadata ?? this.metadata;
  }

  @override
  String toString() {
    return 'OperationInput('
        'operationName: $operationName, '
        'method: $method, '
        'headers: $headers, '
        'parameters: $parameters, '
        'body: $body, '
        'bucket: $bucket, '
        'key: $key, '
        'metadata: $metadata)';
  }
}
