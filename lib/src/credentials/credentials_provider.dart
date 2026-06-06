import 'credentials.dart';

/// Abstract base class for providing credentials.
abstract class CredentialsProvider {
  /// Gets the credentials.
  ///
  /// Returns a [Future] that completes with [Credentials].
  /// Throws an exception if credentials cannot be obtained.
  Future<Credentials> getCredentials();
}
