import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/oss_utils.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/xml_parser.dart';

void main() {
  group('Utils Tests', () {
    test('testVerifyEffectivenessOfBucketName', () {
      const bucketName1 = 'examplebucket1';
      const bucketName2 = 'test-bucket-2021';
      const bucketName3 = 'aliyun-oss-bucket';

      const bucketName4 = 'Examplebucket1';
      const bucketName5 = 'test_bucket_2021';
      const bucketName6 = 'aliyun-oss-bucket-';

      expect(bucketName1.isValidBucketName(), isTrue);
      expect(bucketName2.isValidBucketName(), isTrue);
      expect(bucketName3.isValidBucketName(), isTrue);

      expect(bucketName4.isValidBucketName(), isFalse);
      expect(bucketName5.isValidBucketName(), isFalse);
      expect(bucketName6.isValidBucketName(), isFalse);
    });

    test('testIsIPAddress', () {
      const ipv4 = '192.168.1.1';
      const ipv6 = 'fe80::200:ff:fe00:400';
      const host = 'oss-cn-hangzhou.aliyuncs.com';
      const localhost = 'localhost';

      expect(ipv4.isIPAddress(), isTrue);
      expect(ipv6.isIPAddress(), isTrue);

      expect(host.isIPAddress(), isFalse);
      expect(localhost.isIPAddress(), isFalse);
    });

    test('testXMLParser', () {
      // withXMLDataError
      var xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>';
      var xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      var (root, error) = DictionaryXMLExtensions.withXMLDataError(xmlBody);
      expect(root['Delete'], isNotNull);
      if (root['Delete'] is Map<String, dynamic>) {
        final delete = root['Delete'] as Map<String, dynamic>;
        expect(delete['Quiet'], equals('false'));
        expect(delete['Object'], isNotNull);
        if (delete['Object'] is List) {
          final objects = delete['Object'] as List;
          expect((objects[0] as Map)['Key'], equals('multipart.data'));
          expect((objects[1] as Map)['Key'], equals('test.jpg'));
          expect((objects[2] as Map)['Key'], equals('demo.jpg'));
        }
      }

      xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key>';
      xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      (root, error) = DictionaryXMLExtensions.withXMLDataError(xmlBody);
      expect(error, isNotNull);

      xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>';
      xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      (root, error) = DictionaryXMLExtensions.withXMLDataError(xmlBody);
      expect(error, isNotNull);

      // withXMLData
      xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>';
      xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      root = DictionaryXMLExtensions.withXMLData(xmlBody);
      expect(root['Delete'], isNotNull);
      if (root['Delete'] is Map<String, dynamic>) {
        final delete = root['Delete'] as Map<String, dynamic>;
        expect(delete['Quiet'], equals('false'));
        expect(delete['Object'], isNotNull);
        if (delete['Object'] is List) {
          final objects = delete['Object'] as List;
          expect((objects[0] as Map)['Key'], equals('multipart.data'));
          expect((objects[1] as Map)['Key'], equals('test.jpg'));
          expect((objects[2] as Map)['Key'], equals('demo.jpg'));
        }
      }

      xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key>';
      xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      expect(
        () => DictionaryXMLExtensions.withXMLData(xmlBody),
        throwsException,
      );

      xmlBodyString =
          '<?xml version="1.0" encoding="UTF-8"?><Delete><>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>';
      xmlBody = Uint8List.fromList(utf8.encode(xmlBodyString));
      expect(
        () => DictionaryXMLExtensions.withXMLData(xmlBody),
        throwsException,
      );
    });

    test('testEscape', () {
      const string1 =
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],./-_=+';
      const string2 =
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],\'."/<->_&=+';
      const escapeString2 =
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],&apos;.&quot;/&lt;-&gt;_&amp;=+';

      expect(string1.escape(), equals(string1));
      expect(string2.escape(), equals(escapeString2));
    });

    test('testEncodedQuery', () {
      Map<String, dynamic> parameters = <String, dynamic>{};

      expect(parameters.encodedQuery(), equals(''));

      parameters = {'key': 'value'};
      expect(parameters.encodedQuery(), equals('key=value'));

      parameters = {'key1': 'value1', 'key2': 'value2'};
      final result = parameters.encodedQuery();
      expect(
        result == 'key1=value1&key2=value2' ||
            result == 'key2=value2&key1=value1',
        isTrue,
      );
    });

    test('testURLEncode', () {
      const string =
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~/ *=+`!@#\$%^&()\\|;\':",<>?';
      final urlEncodedString = string.urlEncode();
      expect(
        urlEncodedString,
        equals(
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~%2F%20%2A%3D%2B%60%21%40%23%24%25%5E%26%28%29%5C%7C%3B%27%3A%22%2C%3C%3E%3F',
        ),
      );

      final urlEncodedStringWithoutSeparator = string
          .urlEncodeWithoutSeparator();
      expect(
        urlEncodedStringWithoutSeparator,
        equals(
          'abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~/%20%2A%3D%2B%60%21%40%23%24%25%5E%26%28%29%5C%7C%3B%27%3A%22%2C%3C%3E%3F',
        ),
      );
    });

    test('testToBase64JsonString', () {
      Map<String, String> dic = {'key1': 'value1', 'key2': 'value2'};
      final base64String = dic.toBase64JsonString();
      expect(
        base64String == 'eyJrZXkxIjoidmFsdWUxIiwia2V5MiI6InZhbHVlMiJ9' ||
            base64String == 'eyJrZXkyIjoidmFsdWUyIiwia2V5MSI6InZhbHVlMSJ9',
        isTrue,
      );

      dic = <String, String>{};
      final emptyBase64String = dic.toBase64JsonString();
      expect(emptyBase64String, equals('e30='));
    });

    test('testToBase64String', () {
      final bytes = utf8.encode('test method toBase64JsonString');
      final base64String = Uint8List.fromList(bytes).toBase64String();
      expect(base64String, equals('dGVzdCBtZXRob2QgdG9CYXNlNjRKc29uU3RyaW5n'));
    });

    test('testCaseInsensitiveString', () {
      final header = <CaseInsensitiveString, String>{};
      final keyLower = CaseInsensitiveString('key');
      final keyCapital = CaseInsensitiveString('Key');
      final keyUpper = CaseInsensitiveString('KEY');

      header[keyCapital] = 'value1';
      expect(header[keyLower], equals('value1'));
      expect(header[keyCapital], equals('value1'));
      expect(header[keyUpper], equals('value1'));

      header[keyLower] = 'value2';
      expect(header[keyLower], equals('value2'));
      expect(header[keyCapital], equals('value2'));
      expect(header[keyUpper], equals('value2'));
    });
  });
}
