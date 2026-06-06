import 'byte_stream.dart';
import 'request_message.dart';

/// Response message containing HTTP response data from OSS operations
class ResponseMessage {
  /// HTTP status code of the response
  int statusCode;

  /// HTTP headers from the response
  Map<String, String> headers;

  /// Response body content as ByteStream
  ByteStream? content;

  /// The original request that generated this response
  RequestMessage? request;

  /// Creates a new ResponseMessage instance
  ResponseMessage({
    this.statusCode = 0,
    Map<String, String>? headers,
    this.content,
    this.request,
  }) : headers = headers ?? <String, String>{};

  /// Creates a copy of this ResponseMessage with optional parameter overrides
  ResponseMessage copyWith({
    int? statusCode,
    Map<String, String>? headers,
    ByteStream? content,
    RequestMessage? request,
  }) {
    return ResponseMessage(
      statusCode: statusCode ?? this.statusCode,
      headers: headers ?? Map<String, String>.from(this.headers),
      content: content ?? this.content,
      request: request ?? this.request,
    );
  }

  @override
  String toString() {
    final headerString = headers.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n\t\t');

    if (request != null) {
      return 'response\n'
          'request url: ${request!.requestUri}\n'
          'status code: $statusCode\n'
          'header: $headerString';
    } else {
      return 'response\n'
          'status code: $statusCode\n'
          'header: $headerString';
    }
  }
}
