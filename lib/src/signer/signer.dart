import '../types/request_message.dart';
import 'signing_context.dart';

/// Interface for signing OSS requests
abstract class Signer {
  /// Creates a Signer instance.
  const Signer();

  /// Signs the given request with the provided signing context
  ///
  /// Parameters:
  /// - [request]: The request message to be signed
  /// - [signingContext]: The context containing signing information
  ///
  /// Returns: The signed request message
  ///
  /// Throws: Exception if signing fails
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  );
}

/// Interface for custom signature delegation
abstract class SignatureDelegate {
  /// Creates a SignatureDelegate instance.
  const SignatureDelegate();

  /// Generates signature information based on the provided info
  ///
  /// Parameters:
  /// - [info]: A map containing signature-related information
  ///
  /// Returns: A map containing the generated signature information
  ///
  /// Throws: Exception if signature generation fails
  Future<Map<String, String>> signature(Map<String, String> info);
}
