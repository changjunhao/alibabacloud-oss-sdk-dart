import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_transfer_acceleration.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_transfer_acceleration.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketTransferAcceleration Tests', () {
    test('testSerializePutBucketTransferAcceleration', () async {
      var input = OperationInput(
        operationName: 'PutBucketTransferAcceleration',
        method: 'PUT',
      );

      // Test with empty configuration
      var request = PutBucketTransferAccelerationRequest(
        transferAccelerationConfiguration: TransferAccelerationConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketTransferAcceleration
              .serializePutBucketTransferAcceleration,
        ],
      );
      final emptyBody = await input.body?.readData();
      expect(emptyBody, isNotNull);
      final emptyXml = utf8.decode(emptyBody!);
      expect(emptyXml, contains('<TransferAccelerationConfiguration>'));
      expect(emptyXml, contains('</TransferAccelerationConfiguration>'));

      // Test with enabled = true
      input = OperationInput(
        operationName: 'PutBucketTransferAcceleration',
        method: 'PUT',
      );
      request = PutBucketTransferAccelerationRequest(
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketTransferAcceleration
              .serializePutBucketTransferAcceleration,
        ],
      );
      final body = await input.body?.readData();
      expect(body, isNotNull);
      final xml = utf8.decode(body!);
      expect(xml, contains('<Enabled>true</Enabled>'));
      expect(xml, contains('<TransferAccelerationConfiguration>'));
      expect(xml, contains('</TransferAccelerationConfiguration>'));
    });

    test('testDeserializeGetBucketTransferAcceleration', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketTransferAccelerationResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketTransferAcceleration
                .deserializeGetBucketTransferAcceleration,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with unexpected body - should throw
      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      result = GetBucketTransferAccelerationResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketTransferAcceleration
                .deserializeGetBucketTransferAcceleration,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '<TransferAccelerationConfiguration>'
          '<Enabled>true</Enabled>'
          '</TransferAccelerationConfiguration>';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketTransferAccelerationResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketTransferAcceleration
              .deserializeGetBucketTransferAcceleration,
        ],
      );

      expect(result.transferAccelerationConfiguration?.enabled, equals(true));
    });
  });
}
