import '../credentials/credentials_provider.dart';
import '../retry/retryer.dart';
import '../signer/signer.dart';
import '../enums.dart';
import '../internal/execute_middleware.dart';

/// Client options for configuring OSS client behavior
class ClientOptions {
  /// Product name
  String product;

  /// Region where the bucket is located
  String region;

  /// Custom endpoint URL
  Uri? endpoint;

  /// Maximum retry attempts
  int retryMaxAttempts;

  /// Retry strategy
  Retryer retryer;

  /// Request signer
  Signer signer;

  /// Credentials provider
  CredentialsProvider? credentialsProvider;

  /// Address style type
  AddressStyleType addressStyle;

  /// Authentication method
  String? authMethod;

  /// Feature flags
  FeatureFlag featureFlags;

  /// Additional headers to include in requests
  List<String> additionalHeaders;

  /// The middleware to send request, use for test
  ExecuteMiddleware? executeMW;

  /// Creates a new ClientOptions instance
  ClientOptions({
    required this.product,
    required this.region,
    this.endpoint,
    required this.retryMaxAttempts,
    required this.retryer,
    required this.signer,
    this.credentialsProvider,
    required this.addressStyle,
    this.authMethod,
    required this.featureFlags,
    List<String>? additionalHeaders,
    this.executeMW,
  }) : additionalHeaders = additionalHeaders ?? [];

  /// Creates a copy of this ClientOptions with optional parameter overrides
  ClientOptions copyWith({
    String? product,
    String? region,
    Uri? endpoint,
    int? retryMaxAttempts,
    Retryer? retryer,
    Signer? signer,
    CredentialsProvider? credentialsProvider,
    AddressStyleType? addressStyle,
    String? authMethod,
    FeatureFlag? featureFlags,
    List<String>? additionalHeaders,
    ExecuteMiddleware? executeMW,
  }) {
    return ClientOptions(
      product: product ?? this.product,
      region: region ?? this.region,
      endpoint: endpoint ?? this.endpoint,
      retryMaxAttempts: retryMaxAttempts ?? this.retryMaxAttempts,
      retryer: retryer ?? this.retryer,
      signer: signer ?? this.signer,
      credentialsProvider: credentialsProvider ?? this.credentialsProvider,
      addressStyle: addressStyle ?? this.addressStyle,
      authMethod: authMethod ?? this.authMethod,
      featureFlags: featureFlags ?? this.featureFlags,
      additionalHeaders:
          additionalHeaders ?? List<String>.from(this.additionalHeaders),
      executeMW: executeMW ?? this.executeMW,
    );
  }
}

/// Type alias for client options action function
typedef ClientOptionsAction = void Function(ClientOptions options);
