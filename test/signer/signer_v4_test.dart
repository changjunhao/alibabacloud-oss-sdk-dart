import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signer_v4.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signing_context.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/request_message.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/credentials.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/oss_utils.dart';

void main() {
  group('SignerV4Tests', () {
    setUp(() {
      // Put setup code here. This method is called before the invocation of each test method in the group.
    });

    tearDown(() {
      // Put teardown code here. This method is called after the invocation of each test method in the group.
    });

    test('testAuthHeader', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

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

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702743657 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
      );
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      const authPat = 'OSS4-HMAC-SHA256 Credential=ak/20231216/cn-hangzhou/oss/aliyun_v4_request,Signature=e21d18daa82167720f9b1047ae7e7f1ce7cb77a31e8203a7d5f4624fa0284afe';
      expect(request.headers['Authorization'], equals(authPat));

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2='), isTrue);
      expect(urlStr.contains('%2Bparam1=value3'), isTrue);
    });

    test('testAuthHeaderToken', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
        securityToken: 'token',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

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

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702784856 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
      );
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      const authPat = 'OSS4-HMAC-SHA256 Credential=ak/20231217/cn-hangzhou/oss/aliyun_v4_request,Signature=b94a3f999cf85bcdc00d332fbd3734ba03e48382c36fa4d5af5df817395bd9ea';
      expect(request.headers['Authorization'], equals(authPat));

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2='), isTrue);
      expect(urlStr.contains('%2Bparam1=value3&'), isTrue);
    });

    test('testAuthHeaderWithAdditionalHeaders', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      // case 1
      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'text/plain',
        'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702747512 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
        additionalHeaderNames: ['ZAbc', 'abc'],
      );
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      const authPat = 'OSS4-HMAC-SHA256 Credential=ak/20231216/cn-hangzhou/oss/aliyun_v4_request,AdditionalHeaders=abc;zabc,Signature=4a4183c187c07c8947db7620deb0a6b38d9fbdd34187b6dbaccb316fa251212f';
      expect(request.headers['Authorization'], equals(authPat));

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2='), isTrue);
      expect(urlStr.contains('%2Bparam1=value3'), isTrue);

      // with default signed header
      var request1 = RequestMessage(method: 'PUT', requestUri: uri);
      request1.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'text/plain',
        'x-oss-content-sha256': 'UNSIGNED-PAYLOAD',
      };

      final signTime1 = DateTime.fromMillisecondsSinceEpoch(1702747512 * 1000, isUtc: true);

      var signingContext1 = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime1,
        credentials: credentials,
        additionalHeaderNames: ['x-oss-no-exist', 'ZAbc', 'x-oss-head1', 'abc'],
      );
      
      request1 = await signer.sign(request1, signingContext1);
      expect(request1.headers['Authorization'], equals(authPat));
    });

    test('testAuthQuery', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'application/octet-stream',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702781677 * 1000, isUtc: true);
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(1702782276 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
        expirationTime: expirationTime,
      );
      signingContext.authHeader = false;
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      expect(urlStr.contains('x-oss-signature-version=OSS4-HMAC-SHA256'), isTrue);
      expect(urlStr.contains('x-oss-expires=599'), isTrue);
      expect(urlStr.contains('x-oss-credential=ak%2F20231217%2Fcn-hangzhou%2Foss%2Faliyun_v4_request'), isTrue);
      expect(urlStr.contains('x-oss-signature=a39966c61718be0d5b14e668088b3fa07601033f6518ac7b523100014269c0fe'), isTrue);
      expect(urlStr.contains('x-oss-additional-headers'), isFalse);

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2=&'), isTrue);
      expect(urlStr.contains('%2Bparam1=value3&'), isTrue);
    });

    test('testAuthQueryToken', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
        securityToken: 'token',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'application/octet-stream',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702785388 * 1000, isUtc: true);
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(1702785987 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
        expirationTime: expirationTime,
      );
      signingContext.authHeader = false;
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      expect(urlStr.contains('x-oss-signature-version=OSS4-HMAC-SHA256'), isTrue);
      expect(urlStr.contains('x-oss-date=20231217T035628Z'), isTrue);
      expect(urlStr.contains('x-oss-expires=599'), isTrue);
      expect(urlStr.contains('x-oss-credential=ak%2F20231217%2Fcn-hangzhou%2Foss%2Faliyun_v4_request'), isTrue);
      expect(urlStr.contains('x-oss-signature=3817ac9d206cd6dfc90f1c09c00be45005602e55898f26f5ddb06d7892e1f8b5'), isTrue);
      expect(urlStr.contains('x-oss-security-token=token'), isTrue);
      expect(urlStr.contains('x-oss-additional-headers'), isFalse);

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2=&'), isTrue);
      expect(urlStr.contains('%2Bparam1=value3&'), isTrue);
    });

    test('testAuthQueryWithAdditionalHeaders', () async {
      const credentials = Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
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
      
      final queries = parameters.entries.map((entry) {
        final name = entry.key.urlEncode();
        final value = entry.value?.urlEncode();
        if (name != null) {
          return '$name=${value ?? ''}';
        } else {
          return '';
        }
      }).join('&');

      final uri = Uri.parse('$host/${path.urlEncodePath()}?$queries');

      // case 1
      var request = RequestMessage(method: 'PUT', requestUri: uri);
      request.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'application/octet-stream',
      };

      final signTime = DateTime.fromMillisecondsSinceEpoch(1702783809 * 1000, isUtc: true);
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(1702784408 * 1000, isUtc: true);

      var signingContext = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
        additionalHeaderNames: ['ZAbc', 'abc'],
        expirationTime: expirationTime,
      );
      signingContext.authHeader = false;
      
      const signer = SignerV4();
      request = await signer.sign(request, signingContext);
      final urlStr = request.requestUri.toString();

      expect(urlStr.contains('x-oss-signature-version=OSS4-HMAC-SHA256'), isTrue);
      expect(urlStr.contains('x-oss-date=20231217T033009Z'), isTrue);
      expect(urlStr.contains('x-oss-expires=599'), isTrue);
      expect(urlStr.contains('x-oss-credential=ak%2F20231217%2Fcn-hangzhou%2Foss%2Faliyun_v4_request'), isTrue);
      expect(urlStr.contains('x-oss-signature=6bd984bfe531afb6db1f7550983a741b103a8c58e5e14f83ea474c2322dfa2b7'), isTrue);
      expect(urlStr.contains('x-oss-additional-headers=abc%3Bzabc'), isTrue);

      expect(urlStr.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr.contains('%2Bparam2=&'), isTrue);
      expect(urlStr.contains('%2Bparam1=value3&'), isTrue);

      // with default signed header
      var request1 = RequestMessage(method: 'PUT', requestUri: uri);
      request1.headers = {
        'x-oss-head1': 'value',
        'abc': 'value',
        'ZAbc': 'value',
        'XYZ': 'value',
        'content-type': 'application/octet-stream',
      };

      var signingContext1 = SigningContext(
        bucket: 'bucket',
        key: '1234+-/123/1.txt',
        region: 'cn-hangzhou',
        product: 'oss',
        signTime: signTime,
        credentials: credentials,
        additionalHeaderNames: ['x-oss-no-exist', 'abc', 'x-oss-head1', 'ZAbc'],
        expirationTime: expirationTime,
      );
      signingContext1.authHeader = false;
      
      request1 = await signer.sign(request1, signingContext1);
      final urlStr1 = request1.requestUri.toString();

      expect(urlStr1.contains('x-oss-signature-version=OSS4-HMAC-SHA256'), isTrue);
      expect(urlStr1.contains('x-oss-date=20231217T033009Z'), isTrue);
      expect(urlStr1.contains('x-oss-expires=599'), isTrue);
      expect(urlStr1.contains('x-oss-credential=ak%2F20231217%2Fcn-hangzhou%2Foss%2Faliyun_v4_request'), isTrue);
      expect(urlStr1.contains('x-oss-signature=6bd984bfe531afb6db1f7550983a741b103a8c58e5e14f83ea474c2322dfa2b7'), isTrue);
      expect(urlStr1.contains('x-oss-additional-headers=abc%3Bzabc'), isTrue);

      expect(urlStr1.contains('bucket.oss-cn-hangzhou.aliyuncs.com/1234%2B-/123/1.txt?'), isTrue);
      expect(urlStr1.contains('%2Bparam2=&'), isTrue);
      expect(urlStr1.contains('%2Bparam1=value3&'), isTrue);
    });
  });
}