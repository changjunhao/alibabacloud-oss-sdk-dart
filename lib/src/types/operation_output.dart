import 'operation_input.dart';
import 'byte_stream.dart';

/// Operation output containing response data from OSS requests
class OperationOutput {
  /// The original input that generated this output
  final OperationInput? input;

  /// HTTP status code of the response
  final int statusCode;

  /// HTTP headers from the response
  final Map<String, String> headers;

  /// Response body as ByteStream
  ByteStream? body;

  /// Creates a new OperationOutput instance
  OperationOutput({
    this.input,
    required this.statusCode,
    Map<String, String>? headers,
    this.body,
  }) : headers = headers ?? <String, String>{};

  /// Creates a copy of this OperationOutput with optional parameter overrides
  OperationOutput copyWith({
    OperationInput? input,
    int? statusCode,
    Map<String, String>? headers,
    ByteStream? body,
  }) {
    return OperationOutput(
      input: input ?? this.input,
      statusCode: statusCode ?? this.statusCode,
      headers: headers ?? Map<String, String>.from(this.headers),
      body: body ?? this.body,
    );
  }

  @override
  String toString() {
    return 'OperationOutput('
        'input: $input, '
        'statusCode: $statusCode, '
        'headers: $headers, '
        'body: $body)';
  }
}
