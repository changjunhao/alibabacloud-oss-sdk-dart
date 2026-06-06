import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_access_monitor.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_enums.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_access_monitor.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketAccessMonitor Tests', () {
    test('testSerializePutBucketAccessMonitor', () async {
      var input = OperationInput(
        operationName: 'PutBucketAccessMonitor',
        method: 'PUT',
      );

      // Test with status set to Enabled
      var request = PutBucketAccessMonitorRequest(
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketAccessMonitor.serializePutBucketAccessMonitor,
        ],
      );
      final bodyData = await (input.body as DataByteStream).readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<Status>Enabled</Status>'));
      expect(bodyStr, contains('<AccessMonitorConfiguration>'));
      expect(bodyStr, contains('</AccessMonitorConfiguration>'));

      // Test with status set to Disabled
      input = OperationInput(
        operationName: 'PutBucketAccessMonitor',
        method: 'PUT',
      );
      request = PutBucketAccessMonitorRequest(
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.disabled,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketAccessMonitor.serializePutBucketAccessMonitor,
        ],
      );
      final bodyData2 = await (input.body as DataByteStream).readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(bodyStr2, contains('<Status>Disabled</Status>'));
    });

    test('testDeserializeGetBucketAccessMonitor', () async {
      // Test with null body
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketAccessMonitorResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketAccessMonitor.deserializeGetBucketAccessMonitor,
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
      result = GetBucketAccessMonitorResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketAccessMonitor.deserializeGetBucketAccessMonitor,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<AccessMonitorConfiguration>
    <Status>Enabled</Status>
</AccessMonitorConfiguration>
'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketAccessMonitorResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketAccessMonitor.deserializeGetBucketAccessMonitor,
        ],
      );

      expect(
        result.accessMonitorConfiguration?.status,
        equals(AccessMonitorStatus.enabled),
      );
    });
  });
}
