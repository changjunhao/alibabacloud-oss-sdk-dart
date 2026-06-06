import 'dart:convert';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/remote_signer_v4.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signing_context.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/request_message.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/credentials.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signer.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/oss_utils.dart';

/// Mock implementation of SignatureDelegate for testing
class SignatureImpl implements SignatureDelegate {
  @override
  Future<Map<String, String>> signature(Map<String, String> info) async {
    final region = info['region'] ?? '';
    final product = info['product'] ?? '';
    final date = info['date'] ?? '';
    final stringToSign = info['stringToSign'] ?? '';

    // step 2
    const accessKeySecret = 'sk';
    final signingKey = _calcSigningKey(
      accessKeySecret: accessKeySecret,
      region: region,
      product: product,
      date: date,
    );

    // step 3
    final signature = _calcSignature(
      signingKey: signingKey,
      stringToSign: stringToSign,
    );

    return {'signature': signature};
  }

  List<int> _calcSigningKey({
    required String accessKeySecret,
    required String region,
    required String product,
    required String date,
  }) {
    final kDate = Hmac(
      sha256,
      utf8.encode('aliyun_v4$accessKeySecret'),
    ).convert(utf8.encode(date));
    final kRegion = Hmac(sha256, kDate.bytes).convert(utf8.encode(region));
    final kProduct = Hmac(sha256, kRegion.bytes).convert(utf8.encode(product));
    final kSigning = Hmac(
      sha256,
      kProduct.bytes,
    ).convert(utf8.encode('aliyun_v4_request'));
    return kSigning.bytes;
  }

  String _calcSignature({
    required List<int> signingKey,
    required String stringToSign,
  }) {
    final kSignature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign));
    return kSignature.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

void main() {
  group('RemoteSignerV4Tests', () {
    test('testAuthHeader', () async {
      const credentials = Credentials(accessKeyId: 'ak', accessKeySecret: 'sk');
      const path = '1234+-/123/1.txt';
      const host = 'http://bucket.oss-cn-hangzhou.aliyuncs.com';
      final parameters = <String, String?>{
        'param1': 'value1',
        '+param1': 'value3',
        '|param1': 'value4',
        '+param2': '',
        '|param2': '',
        'param2': '',
      };
      final queries = parameters.entries
          .map((entry) {
            final name = entry.key.urlEncode();
            final value = entry.value?.urlEncode();
            if (name != null) {
              return '$name=${value ?? ''}';
            } else {
              return '';
            }
          })
          .join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'text/plain',
        'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1702743657 * 1000,
        isUtc: true,
      );

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
      );
      final signer = RemoteSignerV4(delegate: SignatureImpl());
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      const authPat =
          'OSS4-HMAC-SHA256 Credential=ak/20231216/cn-hangzhou/oss/aliyun_v4_request,Signature=e21d18daa82167720f9b1047ae7e7f1ce7cb77a31e8203a7d5f4624fa0284afe';
      expect(request.headers['Authorization'], equals(authPat));

      expect(
        urlStr.contains(
          'bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?',
        ),
        isTrue,
      );
      expect(urlStr.contains('%2Bparam2='), isTrue);
      expect(urlStr.contains('%2Bparam1=value3'), isTrue);
    });

    test('testAuthQuery', () async {
      const credentials = Credentials(accessKeyId: 'ak', accessKeySecret: 'sk');
      const path = '1234+-/123/1.txt';
      const host = 'http://bucket.oss-cn-hangzhou.aliyuncs.com';
      final parameters = <String, String?>{
        'param1': 'value1',
        '+param1': 'value3',
        '|param1': 'value4',
        '+param2': '',
        '|param2': '',
        'param2': '',
      };
      final queries = parameters.entries
          .map((entry) {
            final name = entry.key.urlEncode();
            final value = entry.value?.urlEncode();
            if (name != null) {
              return '$name=${value ?? ''}';
            } else {
              return '';
            }
          })
          .join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'application/octet-stream',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1702781677 * 1000,
        isUtc: true,
      );
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        1702782276 * 1000,
        isUtc: true,
      );

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
      );
      signingContext.expirationTime = expirationTime;
      signingContext.authHeader = false;
      final signer = RemoteSignerV4(delegate: SignatureImpl());
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      expect(
        urlStr.contains('x-oss-signature-version=OSS4-HMAC-SHA256'),
        isTrue,
      );
      expect(urlStr.contains('x-oss-expires=599'), isTrue);
      expect(
        urlStr.contains(
          'x-oss-credential=ak%2F20231217%2Fcn-hangzhou%2Foss%2Faliyun_v4_request',
        ),
        isTrue,
      );
      expect(
        urlStr.contains(
          'x-oss-signature=a39966c61718be0d5b14e668088b3fa07601033f6518ac7b523100014269c0fe',
        ),
        isTrue,
      );
      expect(urlStr.contains('x-oss-additional-headers'), isFalse);

      expect(
        urlStr.contains(
          'bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?',
        ),
        isTrue,
      );
      expect(urlStr.contains('%2Bparam2=&'), isTrue);
      expect(urlStr.contains('%2Bparam1=value3&'), isTrue);
    });
  });
}
