import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('SignerV1Tests', () {
    setUp(() {
      // Put setup code here. This method is called before the invocation of each test method in the group.
    });

    tearDown(() {
      // Put teardown code here. This method is called after the invocation of each test method in the group.
    });

    // MARK: - sign

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
      const signer = SignerV1();

      // case 1
      var uri = Uri.parse('http://examplebucket.oss-cn-hangzhou.aliyuncs.com');
      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers['content-md5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['content-type'] = 'text/html';
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
      request.headers['content-md5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['content-type'] = 'text/html';
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
      request.headers['content-md5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['content-type'] = 'text/html';
      request.headers['x-oss-meta-author'] = 'alice';
      request.headers['x-oss-meta-magic'] = 'abracadabra';
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request.headers['user-agent'] = 'test';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:/afkugFbmWDQ967j1vr6zygBLQk='),
      );

      // No x-oss-* headers, with content-md5 and content-type
      // Verifies Bug fix 1: content-md5/content-type found via lowercase keys
      // Verifies Bug fix 2: no extra \n when no x-oss-* headers
      signingContext = SigningContext(
        bucket: 'examplebucket',
        signTime: signTime,
        credentials: credentials,
      );
      uri = Uri.parse('http://examplebucket.oss-cn-hangzhou.aliyuncs.com');
      request = RequestMessage(method: 'GET', requestUri: uri);
      request.headers['content-md5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['content-type'] = 'text/html';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:5j7Zlb7Y41i+YhXU80V5MUpdluk='),
      );

      // No x-oss-* headers, no content-md5, no content-type
      // Verifies Bug fix 2: no extra \n when CanonicalizedOSSHeaders is empty
      signingContext = SigningContext(
        bucket: 'examplebucket',
        signTime: signTime,
        credentials: credentials,
      );
      uri = Uri.parse('http://examplebucket.oss-cn-hangzhou.aliyuncs.com');
      request = RequestMessage(method: 'GET', requestUri: uri);
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:sBtBCZz4kHYnmKTlKyAFVLwQRMw='),
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

    test('testAuthHeaderToken', () async {
      const ak = 'ak';
      const sk = 'sk';
      const token = 'token';
      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1672223261 * 1000,
        isUtc: true,
      );

      const credentials = Credentials(
        accessKeyId: ak,
        accessKeySecret: sk,
        securityToken: token,
      );
      var signingContext = SigningContext(
        bucket: 'examplebucket',
        key: 'nelson',
        signTime: signTime,
        credentials: credentials,
      );
      const signer = SignerV1();

      // case 1
      final uri = Uri.parse(
        'http://examplebucket.oss-cn-hangzhou.aliyuncs.com',
      );
      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers['content-md5'] = 'eB5eJF1ptWaXm4bijSPyxw==';
      request.headers['content-type'] = 'text/html';
      request.headers['x-oss-meta-author'] = 'alice';
      request.headers['x-oss-meta-magic'] = 'abracadabra';
      request.headers['x-oss-date'] = 'Wed, 28 Dec 2022 10:27:41 GMT';
      request = await signer.sign(request, signingContext);
      expect(
        request.headers['Authorization'],
        equals('OSS ak:H3PAlN3Vucn74tPVEqaQC4AnLwQ='),
      );
      expect(request.headers['x-oss-security-token'], equals(token));
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
      const signer = SignerV1();

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

    test('testAuthQueryToken', () async {
      const ak = 'ak';
      const sk = 'sk';
      const token = 'token';
      final signTime = DateTime.fromMillisecondsSinceEpoch(
        1699808204 * 1000,
        isUtc: true,
      );

      const credentials = Credentials(
        accessKeyId: ak,
        accessKeySecret: sk,
        securityToken: token,
      );
      var signingContext = SigningContext(
        bucket: 'bucket',
        key: 'key+123',
        signTime: signTime,
        credentials: credentials,
        expirationTime: signTime,
      );
      signingContext.authHeader = false;
      const signer = SignerV1();

      // case 1
      final uri = Uri.parse(
        'http://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123?versionId=versionId',
      );
      var request = RequestMessage(method: 'GET', requestUri: uri);
      request = await signer.sign(request, signingContext);
      expect(
        request.requestUri.queryParameters['OSSAccessKeyId'],
        equals('ak'),
      );
      expect(
        request.requestUri.queryParameters['Expires'],
        equals('1699808204'),
      );
      expect(
        request.requestUri.queryParameters['Signature'],
        equals('jzKYRrM5y6Br0dRFPaTGOsbrDhY%3D'),
      );
      expect(
        request.requestUri.queryParameters['versionId'],
        equals('versionId'),
      );
      expect(request.requestUri.toString().contains('/key%2B123'), isTrue);
    });
  });
}
