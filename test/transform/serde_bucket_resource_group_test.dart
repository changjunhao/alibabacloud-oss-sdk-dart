import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_resource_group.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_resource_group.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketResourceGroup Tests', () {
    test('testSerializePutBucketResourceGroup - with config', () async {
      var input = OperationInput(
        operationName: 'PutBucketResourceGroup',
        method: 'PUT',
      );

      var request = PutBucketResourceGroupRequest(
        bucketResourceGroupConfiguration: BucketResourceGroupConfiguration(
          resourceGroupId: 'rg-aek27tc********',
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketResourceGroup.serializePutBucketResourceGroup,
        ],
      );

      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<BucketResourceGroupConfiguration>'));
      expect(bodyStr, contains('</BucketResourceGroupConfiguration>'));
      expect(
        bodyStr,
        contains('<ResourceGroupId>rg-aek27tc********</ResourceGroupId>'),
      );
    });

    test('testSerializePutBucketResourceGroup - null config', () async {
      var input = OperationInput(
        operationName: 'PutBucketResourceGroup',
        method: 'PUT',
      );

      var request = PutBucketResourceGroupRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketResourceGroup.serializePutBucketResourceGroup,
        ],
      );

      expect(input.body, isNull);
    });

    test('testDeserializeGetBucketResourceGroup - null body', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketResourceGroupResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketResourceGroup.deserializeGetBucketResourceGroup,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketResourceGroup - unexpected body', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetBucketResourceGroupResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketResourceGroup.deserializeGetBucketResourceGroup,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketResourceGroup - normal', () async {
      final xml =
          '''
<BucketResourceGroupConfiguration>
    <ResourceGroupId>rg-aek27tc********</ResourceGroupId>
</BucketResourceGroupConfiguration>'''
              .trim();

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetBucketResourceGroupResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketResourceGroup.deserializeGetBucketResourceGroup,
        ],
      );

      expect(
        result.bucketResourceGroupConfiguration?.resourceGroupId,
        equals('rg-aek27tc********'),
      );
    });
  });
}
