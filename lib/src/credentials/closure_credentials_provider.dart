import 'credentials.dart';
import 'credentials_provider.dart';

/// Type definition for a closure that returns credentials.
typedef GetCredentialsClosure = Future<Credentials> Function();

/// A credentials provider that uses a closure to obtain credentials.
class ClosureCredentialsProvider implements CredentialsProvider {
  final GetCredentialsClosure _closure;

  /// Creates a ClosureCredentialsProvider with the specified closure.
  ///
  /// Parameters:
  /// - [closure]: A function that returns credentials asynchronously.
  const ClosureCredentialsProvider(GetCredentialsClosure closure)
    : _closure = closure;

  @override
  Future<Credentials> getCredentials() async {
    return await _closure();
  }
}
