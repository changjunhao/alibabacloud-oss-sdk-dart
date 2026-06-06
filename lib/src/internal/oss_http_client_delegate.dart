import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// HTTP client delegate for handling SSL/TLS verification and redirects
class OSSHttpClientDelegate {
  final bool enableTLSVerify;
  final bool enableFollowRedirect;

  /// Creates an HTTP client delegate with the specified configuration
  ///
  /// [enableTLSVerify] - Whether to verify SSL/TLS certificates
  /// [enableFollowRedirect] - Whether to follow HTTP redirects
  const OSSHttpClientDelegate({
    required this.enableTLSVerify,
    required this.enableFollowRedirect,
  });

  /// Configures a Dio instance with the delegate's settings
  ///
  /// [dio] - The Dio instance to configure
  void configureDio(Dio dio) {
    // Configure redirect behavior
    dio.options.followRedirects = enableFollowRedirect;

    // Configure SSL/TLS verification
    if (!enableTLSVerify) {
      // Create a custom HttpClient that bypasses certificate verification
      if (dio.httpClientAdapter is IOHttpClientAdapter) {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
      }
    }
  }

  /// Creates a Dio instance with the delegate's configuration applied
  ///
  /// Returns a new Dio instance configured with SSL/TLS and redirect settings
  Dio createConfiguredDio() {
    final dio = Dio();
    configureDio(dio);
    return dio;
  }

  /// Validates a certificate for the given host
  ///
  /// This method provides a way to implement custom certificate validation logic.
  /// In the current implementation, it returns the value of [enableTLSVerify].
  ///
  /// [certificate] - The certificate to validate
  /// [host] - The host name
  /// [port] - The port number
  /// Returns true if the certificate should be accepted, false otherwise
  bool validateCertificate(X509Certificate certificate, String host, int port) {
    if (!enableTLSVerify) {
      return true;
    }

    // In a real implementation, you might want to add custom certificate
    // validation logic here. For now, we rely on the system's default
    // certificate validation when enableTLSVerify is true.
    return enableTLSVerify;
  }

  /// Handles HTTP redirect responses
  ///
  /// [response] - The redirect response
  /// [request] - The original request
  /// Returns true if the redirect should be followed, false otherwise
  bool shouldFollowRedirect(Response response, RequestOptions request) {
    return enableFollowRedirect;
  }

  /// Creates an interceptor that can be added to Dio for handling redirects
  ///
  /// Returns an interceptor that implements custom redirect logic
  Interceptor createRedirectInterceptor() {
    return InterceptorsWrapper(
      onResponse: (response, handler) {
        // Handle redirect responses if custom logic is needed
        if (!enableFollowRedirect &&
            _isRedirectStatusCode(response.statusCode)) {
          // If redirects are disabled, don't follow them
          handler.next(response);
          return;
        }
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    );
  }

  /// Checks if the given status code indicates a redirect
  ///
  /// [statusCode] - The HTTP status code to check
  /// Returns true if the status code indicates a redirect
  bool _isRedirectStatusCode(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 300 && statusCode < 400;
  }

  @override
  String toString() {
    return 'OSSHttpClientDelegate(enableTLSVerify: $enableTLSVerify, enableFollowRedirect: $enableFollowRedirect)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OSSHttpClientDelegate &&
        other.enableTLSVerify == enableTLSVerify &&
        other.enableFollowRedirect == enableFollowRedirect;
  }

  @override
  int get hashCode => Object.hash(enableTLSVerify, enableFollowRedirect);
}

/// Extension methods for creating OSSHttpClientDelegate from Configuration
extension OSSHttpClientDelegateExtension on OSSHttpClientDelegate {
  /// Creates an OSSHttpClientDelegate from configuration values
  ///
  /// [enableTLSVerify] - Whether to verify SSL/TLS certificates (defaults to true)
  /// [enableFollowRedirect] - Whether to follow HTTP redirects (defaults to false)
  static OSSHttpClientDelegate fromConfig({
    bool? enableTLSVerify,
    bool? enableFollowRedirect,
  }) {
    return OSSHttpClientDelegate(
      enableTLSVerify: enableTLSVerify ?? true,
      enableFollowRedirect: enableFollowRedirect ?? false,
    );
  }
}
