import 'package:dio/dio.dart';

/// Operation options for OSS requests
class OperationOptions {
  /// Maximum number of retry attempts
  int? retryMaxAttempts;

  /// Read/write timeout duration in seconds
  Duration? readWriteTimeout;

  /// Internal use only
  /// Used for download operations to save directly to file
  bool saveToURL;

  /// Cancel token for cancelling in-flight requests.
  ///
  /// When `cancelToken.cancel()` is called, the ongoing HTTP request will be
  /// aborted and a `ClientError` with code `RequestCancelled` will be thrown.
  ///
  /// Example:
  /// ```dart
  /// final cancelToken = CancelToken();
  /// final future = client.putObject(request, OperationOptions()..cancelToken = cancelToken);
  /// // Cancel after some time
  /// cancelToken.cancel('user cancelled');
  /// ```
  CancelToken? cancelToken;

  /// Creates a new instance of OperationOptions
  OperationOptions({
    this.retryMaxAttempts,
    this.readWriteTimeout,
    this.cancelToken,
  }) : saveToURL = false;

  /// Creates a copy of this OperationOptions with optionally updated values
  OperationOptions copyWith({
    int? retryMaxAttempts,
    Duration? readWriteTimeout,
    bool? saveToURL,
    CancelToken? cancelToken,
  }) {
    return OperationOptions(
      retryMaxAttempts: retryMaxAttempts ?? this.retryMaxAttempts,
      readWriteTimeout: readWriteTimeout ?? this.readWriteTimeout,
      cancelToken: cancelToken ?? this.cancelToken,
    )..saveToURL = saveToURL ?? this.saveToURL;
  }

  @override
  String toString() {
    return 'OperationOptions('
        'retryMaxAttempts: $retryMaxAttempts, '
        'readWriteTimeout: $readWriteTimeout, '
        'saveToURL: $saveToURL, '
        'cancelToken: $cancelToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperationOptions &&
        other.retryMaxAttempts == retryMaxAttempts &&
        other.readWriteTimeout == readWriteTimeout &&
        other.saveToURL == saveToURL &&
        other.cancelToken == cancelToken;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(
      retryMaxAttempts,
      readWriteTimeout,
      saveToURL,
      cancelToken,
    );
  }
}
