import 'signer.dart';
import 'signer_v1.dart';
import 'signing_context.dart';
import '../types/request_message.dart';
import '../errors/client_errors.dart';

/// RemoteSignerV1 implementation for OSS request signing with remote signature delegation
class RemoteSignerV1 extends SignerV1 {
  /// The signature delegate for remote signing
  final SignatureDelegate delegate;

  /// Creates a new RemoteSignerV1 instance
  ///
  /// Parameters:
  /// - [delegate]: The signature delegate for remote signing
  RemoteSignerV1({required this.delegate});

  @override
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    // step 1
    if (signingContext.authHeader) {
      preAuthHeader(request, signingContext);
    } else {
      preAuthQuery(request, signingContext);
    }

    // step 2 & 3
    final signInfo = <String, String>{
      'version': 'v1',

      // resource
      'method': request.method,
      'bucket': signingContext.bucket ?? '',
      'key': signingContext.key ?? '',

      // signing context
      'stringToSign': signingContext.stringToSign,
      'date': signingContext.dateToSign,
      'accessKeyId': signingContext.credentials?.accessKeyId ?? '',
    };

    late final Map<String, String> signResult;

    try {
      signResult = await delegate.signature(signInfo);
    } catch (error) {
      throw ClientError(
        code: 'SignatureCallError',
        message: 'Remote signature call failed.',
        innerError: error is Exception ? error : Exception(error.toString()),
      );
    }

    // print('signResult:\n$signResult\n');

    final signature = signResult['signature'];
    if (signature == null) {
      throw ClientError(
        code: 'RemoteSignatureError',
        message: 'The signature result don\'t contain signature field.',
      );
    }

    // step 4
    if (signingContext.authHeader) {
      postAuthHeader(request, signingContext, signature);
    } else {
      postAuthQuery(request, signingContext, signature);
    }

    return request;
  }
}
