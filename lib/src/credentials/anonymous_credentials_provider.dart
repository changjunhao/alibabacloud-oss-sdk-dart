import 'credentials.dart';
import 'credentials_provider.dart';

/// A credentials provider that returns anonymous (empty) credentials.
class AnonymousCredentialsProvider implements CredentialsProvider {
  /// Creates an AnonymousCredentialsProvider.
  const AnonymousCredentialsProvider();

  @override
  Future<Credentials> getCredentials() async {
    return const Credentials(accessKeyId: '', accessKeySecret: '');
  }
}
