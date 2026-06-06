import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_policy.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_policy.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketPolicy Tests', () {
    test('testSerializePutBucketPolicy - with body', () async {
      var input = OperationInput(
        operationName: 'PutBucketPolicy',
        method: 'PUT',
      );

      const policyJson =
          '{"Version":"1","Statement":[{"Effect":"Allow","Action":["oss:GetObject"],"Principal":["*"],"Resource":["acs:oss:*:*:mybucket/*"]}]}';

      var request = PutBucketPolicyRequest(body: policyJson);
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketPolicy.serializePutBucketPolicy],
      );

      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, equals(policyJson));
    });

    test('testSerializePutBucketPolicy - null body', () async {
      var input = OperationInput(
        operationName: 'PutBucketPolicy',
        method: 'PUT',
      );

      var request = PutBucketPolicyRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketPolicy.serializePutBucketPolicy],
      );

      expect(input.body, isNull);
    });

    test('testDeserializeGetBucketPolicy - with body', () async {
      const policyJson =
          '{"Version":"1","Statement":[{"Effect":"Allow","Action":["oss:GetObject"],"Principal":["*"],"Resource":["acs:oss:*:*:mybucket/*"]}]}';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(policyJson))),
      );
      var result = GetBucketPolicyResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketPolicy.deserializeGetBucketPolicy],
      );

      expect(result.body, equals(policyJson));
    });

    test('testDeserializeGetBucketPolicy - null body', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketPolicyResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketPolicy.deserializeGetBucketPolicy],
      );

      expect(result.body, isNull);
    });

    test('testDeserializeGetBucketPolicyStatus - null body', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketPolicyStatusResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketPolicy.deserializeGetBucketPolicyStatus,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketPolicyStatus - unexpected body', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetBucketPolicyStatusResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketPolicy.deserializeGetBucketPolicyStatus,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketPolicyStatus - normal', () async {
      final xml =
          '''
<PolicyStatus>
    <IsPublic>true</IsPublic>
</PolicyStatus>'''
              .trim();

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetBucketPolicyStatusResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketPolicy.deserializeGetBucketPolicyStatus,
        ],
      );

      expect(result.policyStatus?.isPublic, equals(true));
    });
  });
}
