import '../types/request_message.dart';
import 'signer.dart';
import 'signing_context.dart';

/// A no-operation signer that returns the request unchanged
///
/// This signer implementation does not perform any actual signing
/// and simply returns the original request message as-is.
class NopSigner implements Signer {
  /// Creates a new NopSigner instance
  const NopSigner();

  @override
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    return request;
  }
}
