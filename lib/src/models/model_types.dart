import '../transform/serde_extensions.dart';

/// Common properties for request models
class RequestModelProp {
  /// The `headers` value.
  Map<String, String>? headers;

  /// The `parameters` value.
  Map<String, String?>? parameters;

  /// Creates a RequestModelProp instance.
  RequestModelProp({this.headers, this.parameters});
}

/// Base interface for request models
abstract class RequestModel {
  /// Creates a RequestModel instance.
  const RequestModel();

  /// Returns the `commonProp` value.
  RequestModelProp get commonProp;
  set commonProp(RequestModelProp value);

  /// Add a header to the request
  void addHeader(String key, String value) {
    commonProp.headers ??= <String, String>{};
    commonProp.headers![key.toLowerCase()] = value;
  }

  /// Add a parameter to the request
  void addParameter(String key, String? value) {
    commonProp.parameters ??= <String, String?>{};
    commonProp.parameters![key] = value;
  }
}

/// Common properties for result models
class ResultModelProp {
  /// The HTTP status code associated with the result.
  int statusCode = 0;

  /// The `headers` value.
  Map<String, String>? headers;

  /// Creates a ResultModelProp instance.
  ResultModelProp();
}

/// Base interface for result models
abstract class ResultModel {
  /// Creates a ResultModel instance.
  const ResultModel();

  /// Returns the `commonProp` value.
  ResultModelProp get commonProp;
  set commonProp(ResultModelProp value);

  /// Get the status code from common properties
  int get statusCode => commonProp.statusCode;

  /// Get the headers from common properties
  Map<String, String>? get headers => commonProp.headers;

  /// Get the request ID from headers using case-insensitive lookup
  String get requestId {
    return commonProp.headers?.getCaseInsensitive('x-oss-request-id') ?? '';
  }
}
