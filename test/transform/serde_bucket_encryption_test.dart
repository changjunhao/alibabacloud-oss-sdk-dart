import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_encryption.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_encryption.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketEncryption Tests', () {
    test('testSerializePutBucketEncryption - empty rule', () async {
      var input = OperationInput(
        operationName: 'PutBucketEncryption',
        method: 'PUT',
      );

      var request = PutBucketEncryptionRequest(
        serverSideEncryptionRule: ServerSideEncryptionRule(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketEncryption.serializePutBucketEncryption],
      );

      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<ServerSideEncryptionRule>'));
      expect(bodyStr, contains('</ServerSideEncryptionRule>'));
    });

    test('testSerializePutBucketEncryption - with all fields', () async {
      var input = OperationInput(
        operationName: 'PutBucketEncryption',
        method: 'PUT',
      );

      var request = PutBucketEncryptionRequest(
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(
                sseAlgorithm: 'AES256',
                kmsMasterKeyId: 'kmsMasterKeyID',
                kmsDataEncryption: 'kmsDataEncryption',
              ),
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketEncryption.serializePutBucketEncryption],
      );

      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<SSEAlgorithm>AES256</SSEAlgorithm>'));
      expect(
        bodyStr,
        contains('<KMSMasterKeyID>kmsMasterKeyID</KMSMasterKeyID>'),
      );
      expect(
        bodyStr,
        contains('<KMSDataEncryption>kmsDataEncryption</KMSDataEncryption>'),
      );
      expect(bodyStr, contains('<ApplyServerSideEncryptionByDefault>'));
      expect(bodyStr, contains('</ApplyServerSideEncryptionByDefault>'));
    });

    test('testSerializePutBucketEncryption - null rule', () async {
      var input = OperationInput(
        operationName: 'PutBucketEncryption',
        method: 'PUT',
      );

      var request = PutBucketEncryptionRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketEncryption.serializePutBucketEncryption],
      );

      expect(input.body, isNull);
    });

    test('testDeserializeGetBucketEncryption - null body', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketEncryptionResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketEncryption.deserializeGetBucketEncryption,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketEncryption - unexpected body', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetBucketEncryptionResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketEncryption.deserializeGetBucketEncryption,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketEncryption - normal', () async {
      final xml =
          '''
<ServerSideEncryptionRule>
    <ApplyServerSideEncryptionByDefault>
        <SSEAlgorithm>AES256</SSEAlgorithm>
        <KMSMasterKeyID>kmsMasterKeyID</KMSMasterKeyID>
        <KMSDataEncryption>kmsDataEncryption</KMSDataEncryption>
    </ApplyServerSideEncryptionByDefault>
</ServerSideEncryptionRule>'''
              .trim();

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetBucketEncryptionResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketEncryption.deserializeGetBucketEncryption,
        ],
      );

      expect(
        result
            .serverSideEncryptionRule
            ?.applyServerSideEncryptionByDefault
            ?.sseAlgorithm,
        equals('AES256'),
      );
      expect(
        result
            .serverSideEncryptionRule
            ?.applyServerSideEncryptionByDefault
            ?.kmsMasterKeyId,
        equals('kmsMasterKeyID'),
      );
      expect(
        result
            .serverSideEncryptionRule
            ?.applyServerSideEncryptionByDefault
            ?.kmsDataEncryption,
        equals('kmsDataEncryption'),
      );
    });
  });
}
