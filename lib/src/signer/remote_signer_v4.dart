import 'signer.dart';
import 'signer_v4.dart';
import 'signing_context.dart';
import '../types/request_message.dart';
import '../errors/client_errors.dart';

/// RemoteSignerV4 implementation for OSS request signing with remote signature delegation
class RemoteSignerV4 extends SignerV4 {
  final SignatureDelegate delegate;

  /// Creates a new RemoteSignerV4 instance with the provided delegate
  ///
  /// Parameters:
  /// - [delegate]: The signature delegate to handle remote signature generation
  const RemoteSignerV4({required this.delegate});

  @override
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    var requestCopy = request;

    // step 1
    if (signingContext.authHeader) {
      preAuthHeader(requestCopy, signingContext);
    } else {
      preAuthQuery(requestCopy, signingContext);
    }

    // step 2 & 3
    final signInfo = <String, String>{
      'version': 'v4',

      // resource
      'method': requestCopy.method,
      'bucket': signingContext.bucket ?? '',
      'key': signingContext.key ?? '',

      // signing context
      'stringToSign': signingContext.stringToSign,
      'region': signingContext.region ?? '',
      'product': signingContext.product ?? '',
      'date': signingContext.dateToSign,
      'accessKeyId': signingContext.credentials!.accessKeyId,
    };

    late Map<String, String> signResult;

    try {
      signResult = await delegate.signature(signInfo);
    } catch (error) {
      throw RemoteSignatureErrors.signatureCallError(error as Exception);
    }

    // print('signResult:\n$signResult\n');

    final signature = signResult['signature'];
    if (signature == null) {
      throw RemoteSignatureErrors.signatureResultRequiredError('signature');
    }

    // step 4
    if (signingContext.authHeader) {
      postAuthHeader(requestCopy, signingContext, signature);
    } else {
      postAuthQuery(requestCopy, signingContext, signature);
    }

    return requestCopy;
  }
}
