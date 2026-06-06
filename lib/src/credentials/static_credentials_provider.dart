import 'credentials.dart';
import 'credentials_provider.dart';

/// A credentials provider that returns static credentials.
class StaticCredentialsProvider implements CredentialsProvider {
  final Credentials _credentials;

  /// Creates a StaticCredentialsProvider with the specified credentials.
  ///
  /// Parameters:
  /// - [accessKeyId]: the access key id.
  /// - [accessKeySecret]: the access key secret.
  /// - [securityToken]: The security token, can be set to null for non-session credentials.
  StaticCredentialsProvider({
    required String accessKeyId,
    required String accessKeySecret,
    String? securityToken,
  }) : _credentials = Credentials(
         accessKeyId: accessKeyId,
         accessKeySecret: accessKeySecret,
         securityToken: securityToken,
       );

  /// Creates a StaticCredentialsProvider with the specified [Credentials] object.
  StaticCredentialsProvider.fromCredentials(Credentials credentials)
    : _credentials = credentials;

  @override
  Future<Credentials> getCredentials() async {
    return _credentials;
  }
}
