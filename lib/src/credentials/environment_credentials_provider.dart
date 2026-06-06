import 'dart:io';

import 'credentials.dart';
import 'credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

/// A credentials provider that reads credentials from environment variables.
///
/// This provider looks for the following environment variables:
/// - OSS_ACCESS_KEY_ID: The access key ID
/// - OSS_ACCESS_KEY_SECRET: The access key secret
/// - OSS_SESSION_TOKEN: The session token (optional)
class EnvironmentCredentialsProvider implements CredentialsProvider {
  /// Creates an EnvironmentCredentialsProvider.
  const EnvironmentCredentialsProvider();

  @override
  Future<Credentials> getCredentials() async {
    final accessKeyId = Platform.environment['OSS_ACCESS_KEY_ID'];
    final accessKeySecret = Platform.environment['OSS_ACCESS_KEY_SECRET'];

    if (accessKeyId == null || accessKeySecret == null) {
      throw ParameterErrors.paramNullOrEmptyError(
        'Environment.OSS_ACCESS_KEY_ID',
      );
    }

    final securityToken = Platform.environment['OSS_SESSION_TOKEN'];

    return Credentials(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
      securityToken: securityToken,
    );
  }
}
