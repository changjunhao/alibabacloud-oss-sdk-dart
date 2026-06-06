import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_archive_directread.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_archive_directread.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketArchiveDirectread Tests', () {
    test('testSerializePutBucketArchiveDirectRead', () async {
      var input = OperationInput(
        operationName: 'PutBucketArchiveDirectRead',
        method: 'PUT',
      );

      // Test with enabled set to true
      var request = PutBucketArchiveDirectReadRequest(
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketArchiveDirectread.serializePutBucketArchiveDirectRead,
        ],
      );
      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<Enabled>true</Enabled>'));
      expect(bodyStr, contains('<ArchiveDirectReadConfiguration>'));
      expect(bodyStr, contains('</ArchiveDirectReadConfiguration>'));

      // Test with enabled set to false
      input = OperationInput(
        operationName: 'PutBucketArchiveDirectRead',
        method: 'PUT',
      );
      request = PutBucketArchiveDirectReadRequest(
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: false,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketArchiveDirectread.serializePutBucketArchiveDirectRead,
        ],
      );
      final bodyData2 = await (input.body as DataByteStream).readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(bodyStr2, contains('<Enabled>false</Enabled>'));
    });

    test('testDeserializeGetBucketArchiveDirectRead', () async {
      // Test with null body
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketArchiveDirectReadResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketArchiveDirectread.deserializeGetBucketArchiveDirectRead,
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
      result = GetBucketArchiveDirectReadResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketArchiveDirectread.deserializeGetBucketArchiveDirectRead,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<ArchiveDirectReadConfiguration>
    <Enabled>true</Enabled>
</ArchiveDirectReadConfiguration>
'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketArchiveDirectReadResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketArchiveDirectread.deserializeGetBucketArchiveDirectRead,
        ],
      );

      expect(result.archiveDirectReadConfiguration?.enabled, equals(true));
    });
  });
}
