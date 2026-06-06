import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_referer.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_referer.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketReferer Tests', () {
    test('testSerializePutBucketReferer', () async {
      var input = OperationInput(
        operationName: 'PutBucketReferer',
        method: 'PUT',
      );

      // Test with empty RefererConfiguration
      var request = PutBucketRefererRequest(
        refererConfiguration: RefererConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketReferer.serializePutBucketReferer],
      );
      final bodyData1 = await input.body!.readData();
      final bodyStr1 = utf8.decode(bodyData1!);
      expect(bodyStr1, contains('<RefererConfiguration>'));
      expect(bodyStr1, contains('</RefererConfiguration>'));
      expect(bodyStr1, isNot(contains('<AllowEmptyReferer>')));

      // Test with full configuration
      input = OperationInput(operationName: 'PutBucketReferer', method: 'PUT');
      request = PutBucketRefererRequest(
        refererConfiguration: RefererConfiguration(
          allowEmptyReferer: false,
          allowTruncateQueryString: true,
          truncatePath: true,
          refererList: RefererList(
            referers: ['http://www.aliyun.com', 'https://www.aliyun.com'],
          ),
          refererBlacklist: RefererBlacklist(
            referers: ['http://www.refuse.com', 'https://*.hack.com'],
          ),
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketReferer.serializePutBucketReferer],
      );
      final bodyData2 = await input.body!.readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(
        bodyStr2,
        contains('<AllowEmptyReferer>false</AllowEmptyReferer>'),
      );
      expect(
        bodyStr2,
        contains('<AllowTruncateQueryString>true</AllowTruncateQueryString>'),
      );
      expect(bodyStr2, contains('<TruncatePath>true</TruncatePath>'));
      expect(bodyStr2, contains('<RefererList>'));
      expect(bodyStr2, contains('<Referer>http://www.aliyun.com</Referer>'));
      expect(bodyStr2, contains('<Referer>https://www.aliyun.com</Referer>'));
      expect(bodyStr2, contains('</RefererList>'));
      expect(bodyStr2, contains('<RefererBlacklist>'));
      expect(bodyStr2, contains('<Referer>http://www.refuse.com</Referer>'));
      expect(bodyStr2, contains('<Referer>https://*.hack.com</Referer>'));
      expect(bodyStr2, contains('</RefererBlacklist>'));
    });

    test('testDeserializeGetBucketReferer', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketRefererResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketReferer.deserializeGetBucketReferer],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with unexpected body - should throw
      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      result = GetBucketRefererResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketReferer.deserializeGetBucketReferer],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<RefererConfiguration>
    <AllowEmptyReferer>false</AllowEmptyReferer>
    <AllowTruncateQueryString>true</AllowTruncateQueryString>
    <TruncatePath>true</TruncatePath>
    <RefererList>
        <Referer>http://www.aliyun.com</Referer>
        <Referer>https://www.aliyun.com</Referer>
    </RefererList>
    <RefererBlacklist>
        <Referer>http://www.refuse.com</Referer>
        <Referer>https://*.hack.com</Referer>
    </RefererBlacklist>
</RefererConfiguration>'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketRefererResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketReferer.deserializeGetBucketReferer],
      );

      expect(result.refererConfiguration?.allowEmptyReferer, equals(false));
      expect(
        result.refererConfiguration?.allowTruncateQueryString,
        equals(true),
      );
      expect(result.refererConfiguration?.truncatePath, equals(true));
      expect(
        result.refererConfiguration?.refererList?.referers,
        equals(['http://www.aliyun.com', 'https://www.aliyun.com']),
      );
      expect(
        result.refererConfiguration?.refererBlacklist?.referers,
        equals(['http://www.refuse.com', 'https://*.hack.com']),
      );
    });
  });
}
