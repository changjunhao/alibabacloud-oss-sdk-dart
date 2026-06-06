/// The result for the presign operation.
class PresignResult {
  /// The HTTP method, which corresponds to the operation.
  /// For example, the HTTP method of the GetObject operation is GET.
  final String method;

  /// The pre-signed URL.
  final String url;

  /// The time when the pre-signed URL expires.
  final DateTime? expiration;

  /// The request headers specified in the request.
  /// For example, if Content-Type is specified for PutObject, Content-Type is returned.
  final Map<String, String>? signedHeaders;

  /// Creates a new [PresignResult] instance.
  const PresignResult({
    required this.method,
    required this.url,
    this.expiration,
    this.signedHeaders,
  });

  /// Creates a [PresignResult] from a JSON map.
  factory PresignResult.fromJson(Map<String, dynamic> json) {
    return PresignResult(
      method: json['method'] as String,
      url: json['url'] as String,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
      signedHeaders: json['signedHeaders'] != null
          ? Map<String, String>.from(json['signedHeaders'] as Map)
          : null,
    );
  }

  /// Converts this [PresignResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'expiration': expiration?.toIso8601String(),
      'signedHeaders': signedHeaders,
    };
  }

  @override
  String toString() {
    return 'PresignResult(method: $method, url: $url, expiration: $expiration, signedHeaders: $signedHeaders)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresignResult &&
        other.method == method &&
        other.url == url &&
        other.expiration == expiration &&
        _mapEquals(other.signedHeaders, signedHeaders);
  }

  @override
  int get hashCode {
    return Object.hash(method, url, expiration, signedHeaders);
  }

  /// Helper method to compare maps for equality.
  bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
