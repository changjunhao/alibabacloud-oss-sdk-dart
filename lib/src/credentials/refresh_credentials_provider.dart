import 'dart:async';
import 'credentials.dart';
import 'credentials_provider.dart';
import 'closure_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/internal/expiring_value.dart';

/// A credentials provider that automatically refreshes credentials before they expire.
class RefreshCredentialsProvider implements CredentialsProvider {
  /// Default refresh interval is 300 seconds (5 minutes)
  static const Duration defaultInterval = Duration(seconds: 300);

  final ExpiringValue<Credentials> _expiringCredential;
  final CredentialsProvider _provider;

  /// Creates a RefreshCredentialsProvider with a closure.
  ///
  /// Parameters:
  /// - [closure]: A function that returns credentials asynchronously.
  /// - [refreshInterval]: The time before expiration to refresh credentials.
  RefreshCredentialsProvider.fromClosure({
    required GetCredentialsClosure closure,
    Duration? refreshInterval,
  }) : _provider = ClosureCredentialsProvider(closure),
       _expiringCredential = ExpiringValue<Credentials>(
         threshold: refreshInterval ?? defaultInterval,
       );

  /// Creates a RefreshCredentialsProvider with another credentials provider.
  ///
  /// Parameters:
  /// - [provider]: The underlying credentials provider.
  /// - [refreshInterval]: The time before expiration to refresh credentials.
  RefreshCredentialsProvider({
    required CredentialsProvider provider,
    Duration? refreshInterval,
  }) : _provider = provider,
       _expiringCredential = ExpiringValue<Credentials>(
         threshold: refreshInterval ?? defaultInterval,
       );

  @override
  Future<Credentials> getCredentials() async {
    return await _expiringCredential.getValue(() async {
      return await _getCredentialAndExpiration(_provider);
    });
  }

  /// Gets credentials and determines expiration time.
  static Future<(Credentials, DateTime)> _getCredentialAndExpiration(
    CredentialsProvider provider,
  ) async {
    final credentials = await provider.getCredentials();
    if (credentials.expiration == null) {
      // If no expiration is set, use a far future date
      return (
        credentials,
        DateTime.fromMillisecondsSinceEpoch(8640000000000000),
      );
    }
    return (credentials, credentials.expiration!);
  }
}
