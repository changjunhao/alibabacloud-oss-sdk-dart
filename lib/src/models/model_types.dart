import '../transform/serde_extensions.dart';

/// Common properties for request models
class RequestModelProp {
  Map<String, String>? headers;
  Map<String, String?>? parameters;

  RequestModelProp({this.headers, this.parameters});
}

/// Base interface for request models
abstract class RequestModel {
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
  int statusCode = 0;
  Map<String, String>? headers;

  ResultModelProp();
}

/// Base interface for result models
abstract class ResultModel {
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
