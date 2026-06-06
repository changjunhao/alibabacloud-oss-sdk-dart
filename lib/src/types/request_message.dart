import 'byte_stream.dart';

/// Request message containing HTTP request data for OSS operations
class RequestMessage {
  /// HTTP method (GET, POST, PUT, DELETE, etc.)
  String method;

  /// Request URI
  Uri requestUri;

  /// HTTP headers in lower key
  Map<String, String> headers;

  /// Request body content as ByteStream
  ByteStream? content;

  /// Creates a new RequestMessage instance
  RequestMessage({
    required this.method,
    required this.requestUri,
    Map<String, String>? headers,
    this.content,
  }) : headers = headers ?? <String, String>{};

  /// Creates a copy of this RequestMessage with optional parameter overrides
  RequestMessage copyWith({
    String? method,
    Uri? requestUri,
    Map<String, String>? headers,
    ByteStream? content,
  }) {
    return RequestMessage(
      method: method ?? this.method,
      requestUri: requestUri ?? this.requestUri,
      headers: headers ?? Map<String, String>.from(this.headers),
      content: content ?? this.content,
    );
  }

  @override
  String toString() {
    final headerString = headers.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n\t\t');

    return 'request\n'
        'method: $method\n'
        'url: $requestUri\n'
        'header: $headerString';
  }
}
