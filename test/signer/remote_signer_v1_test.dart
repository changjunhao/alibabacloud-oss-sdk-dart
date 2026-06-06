import 'dart:convert';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

/// Mock implementation of SignatureDelegate for testing
class SignatureImpl implements SignatureDelegate {
  @override
  Future<Map<String, String>> signature(Map<String, String> info) async {
    final stringToSign = info['stringToSign'] ?? '';

    // step 2
    const accessKeySecret = 'sk';
    final signingKey = _calcSigningKey(accessKeySecret);

    // step 3
    final signature = _calcSignature(signingKey, stringToSign);

    return {'signature': signature};
  }

  List<int> _calcSigningKey(String accessKeySecret) {
    final key = utf8.encode(accessKeySecret);
    return key;
  }

  String _calcSignature(List<int> signingKey, String stringToSign) {
    final content = utf8.encode(stringToSign);
    final hmac = Hmac(sha1, signingKey);
    final digest = hmac.convert(content);
    return base64Encode(digest.bytes);
  }
}

void main() {
  group('RemoteSignerV1Tests', () {
    test('testAuthHeader', () async {
      const ak = 'ak';
      const sk = 'sk';
      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1672223261 * 1000,
        isUtc: true,
      );

      const credentials = Credentials(accessKeyId: ak, accessKeySecret: sk);
      var signingContext = SigningContext(
        bucket: 'examplebucket',
        key: 'nelson',
        signTime: signTime,
        credentials: credentials,
      );
      final signer = RemoteSignerV1(delegate: SignatureImpl());

      // case 1
      var uri = Uri.parse('http://examplebucket.oss-cn-hangzhou.aliyuncs.com');
      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers['Content-MD5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['Content-Type'] = 'text/html';
      request.headers['x-oss-meta-author'] = 'alice';
      request.headers['x-oss-meta-magic'] = 'abracadabra';
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:kSHKmLxlyEAKtZPkJhG9bZb5k7M='),
      );

      // With Signed Parameter
      uri = Uri.parse('http://examplebucket.oss-cn-hangzhou.aliyuncs.com?acl');
      request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers['Content-MD5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['Content-Type'] = 'text/html';
      request.headers['x-oss-meta-author'] = 'alice';
      request.headers['x-oss-meta-magic'] = 'abracadabra';
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:/afkugFbmWDQ967j1vr6zygBLQk='),
      );

      // With signed & non-signed Parameter & non-signed headers
      uri = Uri.parse(
        'http://examplebucket.oss-cn-hangzhou.aliyuncs.com?acl&non-resousce=123',
      );
      request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers['Content-MD5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['Content-Type'] = 'text/html';
      request.headers['x-oss-meta-author'] = 'alice';
      request.headers['x-oss-meta-magic'] = 'abracadabra';
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request.headers['User-Agent'] = 'test';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:/afkugFbmWDQ967j1vr6zygBLQk='),
      );

      // With sub-resource
      uri = Uri.parse(
        'http://examplebucket.oss-cn-hangzhou.aliyuncs.com?resourceGroup&non-resousce=null',
      );
      signingContext = SigningContext(
        bucket: 'examplebucket',
        signTime: signTime,
        credentials: credentials,
        subResource: ['resourceGroup'],
      );
      request = RequestMessage(method: 'GET', requestUri: uri);
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:vkQmfuUDyi1uDi3bKt67oemssIs='),
      );
    });

    test('testAuthQuery', () async {
      const ak = 'ak';
      const sk = 'sk';
      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1699807420 * 1000,
        isUtc: true,
      );

      const credentials = Credentials(accessKeyId: ak, accessKeySecret: sk);
      var signingContext = SigningContext(
        bucket: 'bucket',
        key: 'key',
        signTime: signTime,
        credentials: credentials,
        expirationTime: signTime,
      );
      signingContext.authHeader = false;
      final signer = RemoteSignerV1(delegate: SignatureImpl());

      // case 1
      final uri = Uri.parse(
        'http://bucket.oss-cn-hangzhou.aliyuncs.com/key?versionId=versionId',
      );
      var request = RequestMessage(method: 'GET', requestUri: uri);
      request = await signer.sign(request, signingContext);
      expect(
        request.requestUri.queryParameters['OSSAccessKeyId'],
        equals('ak'),
      );
      expect(
        request.requestUri.queryParameters['Expires'],
        equals('1699807420'),
      );
      expect(
        request.requestUri.queryParameters['Signature'],
        equals('dcLTea%2BYh9ApirQ8o8dOPqtvJXQ%3D'),
      );
      expect(
        request.requestUri.queryParameters['versionId'],
        equals('versionId'),
      );
    });
  });
}
