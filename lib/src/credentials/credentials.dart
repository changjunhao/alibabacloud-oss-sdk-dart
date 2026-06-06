/// Represents credentials for accessing Alibaba Cloud OSS.
class Credentials {
  /// The AccessKeyId property for the credentials.
  final String accessKeyId;

  /// The AccessKeySecret property for the credentials.
  final String accessKeySecret;

  /// The SecurityToken property for the credentials.
  final String? securityToken;

  /// The token's expiration time.
  final DateTime? expiration;

  /// Constructs a Credentials object with supplied accessKeyId, accessKeySecret and securityToken.
  ///
  /// Parameters:
  /// - [accessKeyId]: the access key id.
  /// - [accessKeySecret]: the access key secret.
  /// - [securityToken]: The security token, can be set to null for non-session credentials.
  /// - [expiration]: The token's expiration time.
  const Credentials({
    required this.accessKeyId,
    required this.accessKeySecret,
    this.securityToken,
    this.expiration,
  });

  /// Will credential expire within a certain time
  bool isExpiring({required Duration within}) {
    if (expiration == null) {
      return false;
    }
    return expiration!.difference(DateTime.now()) < within;
  }

  /// Has credential expired
  bool get isExpired {
    return isExpiring(within: Duration.zero);
  }

  /// Check whether the credentials keys are set
  bool isEmpty() {
    return accessKeyId.isEmpty || accessKeySecret.isEmpty;
  }

  @override
  String toString() {
    return 'Credentials(accessKeyId: $accessKeyId, hasSecurityToken: ${securityToken != null}, expiration: $expiration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Credentials &&
        other.accessKeyId == accessKeyId &&
        other.accessKeySecret == accessKeySecret &&
        other.securityToken == securityToken &&
        other.expiration == expiration;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(accessKeyId, accessKeySecret, securityToken, expiration);
  }
}
