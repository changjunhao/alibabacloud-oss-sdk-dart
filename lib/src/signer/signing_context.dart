import '../credentials/credentials.dart';

/// Represents the context for signing OSS requests.
class SigningContext {
  /// The bucket name.
  final String? bucket;

  /// The object key.
  final String? key;

  /// The product name.
  final String? product;

  /// The region.
  final String? region;

  /// Additional header names to include in signing.
  final List<String>? additionalHeaderNames;

  /// Sub-resource parameters.
  final List<String>? subResource;

  /// The expiration time for the signature.
  DateTime? expirationTime;

  /// Clock offset for time synchronization.
  Duration? clockOffset;

  // inout properties
  /// The credentials for signing.
  Credentials? credentials;

  /// The time when signing occurs.
  DateTime? signTime;

  /// Whether to use authorization header.
  bool authHeader;

  // out properties
  /// The string to be signed.
  String stringToSign;

  /// The date string for signing.
  String dateToSign;

  /// The scope string for signing.
  String scopeToSign;

  /// Additional headers to be signed.
  String additionalHeadersToSign;

  /// Constructs a SigningContext with the specified parameters.
  ///
  /// Parameters:
  /// - [bucket]: The bucket name.
  /// - [key]: The object key.
  /// - [region]: The region.
  /// - [product]: The product name.
  /// - [signTime]: The time when signing occurs.
  /// - [credentials]: The credentials for signing.
  /// - [additionalHeaderNames]: Additional header names to include in signing.
  /// - [subResource]: Sub-resource parameters.
  /// - [expirationTime]: The expiration time for the signature.
  /// - [clockOffset]: Clock offset for time synchronization.
  SigningContext({
    this.bucket,
    this.key,
    this.region,
    this.product,
    this.signTime,
    this.credentials,
    this.additionalHeaderNames,
    this.subResource,
    this.expirationTime,
    this.clockOffset,
  }) : authHeader = true,
       stringToSign = '',
       dateToSign = '',
       scopeToSign = '',
       additionalHeadersToSign = '';

  @override
  String toString() {
    return 'SigningContext('
        'bucket: $bucket, '
        'key: $key, '
        'region: $region, '
        'product: $product, '
        'authHeader: $authHeader'
        ')';
  }
}
