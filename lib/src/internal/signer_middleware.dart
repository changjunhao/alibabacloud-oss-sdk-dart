import '../credentials/credentials.dart';
import '../credentials/credentials_provider.dart';
import '../credentials/anonymous_credentials_provider.dart';
import '../errors/client_errors.dart';
import '../logging/log_agent.dart';
import '../signer/signer.dart';
import '../types/request_message.dart';
import '../types/response_message.dart';
import 'execute_context.dart';
import 'execute_middleware.dart';

/// A no-operation credentials provider that returns empty credentials.
class _NopCredentialsProvider implements CredentialsProvider {
  static const Credentials _cred = Credentials(
    accessKeyId: '',
    accessKeySecret: '',
  );

  const _NopCredentialsProvider();

  @override
  Future<Credentials> getCredentials() async {
    return _cred;
  }
}

/// Middleware that handles request signing using the configured signer and credentials provider.
///
/// This middleware:
/// 1. Fetches credentials from the credentials provider
/// 2. Signs the request using the configured signer
/// 3. Passes the signed request to the next middleware in the chain
class SignerMiddleware implements ExecuteMiddleware {
  /// The signer to use for signing requests
  final Signer signer;

  /// The next middleware in the execution chain
  final ExecuteMiddleware nextHandler;

  /// The credentials provider to fetch credentials from
  final CredentialsProvider provider;

  /// Optional logger for debugging
  final LogAgent? _logger;

  /// Creates a new SignerMiddleware.
  ///
  /// Parameters:
  /// - [nextHandler]: The next middleware in the execution chain
  /// - [signer]: The signer to use for signing requests
  /// - [provider]: The credentials provider (defaults to NopCredentialsProvider if null)
  /// - [logger]: Optional logger for debugging
  SignerMiddleware({
    required this.nextHandler,
    required this.signer,
    CredentialsProvider? provider,
    LogAgent? logger,
  }) : provider = provider ?? const _NopCredentialsProvider(),
       _logger = logger;

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    // Skip signing for anonymous credentials provider
    if (provider is AnonymousCredentialsProvider) {
      return await nextHandler.execute(request, context);
    }

    // Fetch credentials
    final Credentials credentials;
    try {
      credentials = await provider.getCredentials();
    } catch (error) {
      throw CredentialsErrors.credentialsFetchError(
        innerError: error as Exception?,
      );
    }

    // Check if credentials are empty
    if (credentials.isEmpty()) {
      throw CredentialsErrors.credentialsEmptyError();
    }

    // Set credentials in signing context
    if (context.signingContext != null) {
      context.signingContext!.credentials = credentials;
    }

    // Sign the request
    final signedRequest = await signer.sign(request, context.signingContext!);

    // Log the string to sign for debugging
    _logger?.info('stringToSign: \n${context.signingContext!.stringToSign}');

    // Execute the next middleware with the signed request
    return await nextHandler.execute(signedRequest, context);
  }
}
