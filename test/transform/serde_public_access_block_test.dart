import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_public_access_block.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_public_access_block.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_public_access_block.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdePublicAccessBlock Tests', () {
    test('testSerializePutPublicAccessBlock', () async {
      var input = OperationInput(
        operationName: 'PutPublicAccessBlock',
        method: 'PUT',
      );

      // Test with blockPublicAccess set to true
      var request = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdePublicAccessBlock.serializePutPublicAccessBlock,
        ],
      );
      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<BlockPublicAccess>true</BlockPublicAccess>'));
      expect(bodyStr, contains('<PublicAccessBlockConfiguration>'));
      expect(bodyStr, contains('</PublicAccessBlockConfiguration>'));

      // Test with blockPublicAccess set to false
      input = OperationInput(
        operationName: 'PutPublicAccessBlock',
        method: 'PUT',
      );
      request = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: false,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdePublicAccessBlock.serializePutPublicAccessBlock,
        ],
      );
      final bodyData2 = await (input.body as DataByteStream).readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(
        bodyStr2,
        contains('<BlockPublicAccess>false</BlockPublicAccess>'),
      );
    });

    test('testDeserializeGetPublicAccessBlock', () async {
      // Test with null body
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetPublicAccessBlockResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdePublicAccessBlock.deserializeGetPublicAccessBlock,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with unexpected body
      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      result = GetPublicAccessBlockResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdePublicAccessBlock.deserializeGetPublicAccessBlock,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<PublicAccessBlockConfiguration>
    <BlockPublicAccess>true</BlockPublicAccess>
</PublicAccessBlockConfiguration>
'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetPublicAccessBlockResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdePublicAccessBlock.deserializeGetPublicAccessBlock,
        ],
      );

      expect(
        result.publicAccessBlockConfiguration?.blockPublicAccess,
        equals(true),
      );
    });
  });
}
