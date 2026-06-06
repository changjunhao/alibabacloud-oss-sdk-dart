import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_logging.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_logging.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketLogging Tests', () {
    test('testSerializePutBucketLogging', () async {
      var input = OperationInput(
        operationName: 'PutBucketLogging',
        method: 'PUT',
      );

      // Test with empty BucketLoggingStatus
      var request = PutBucketLoggingRequest(
        bucketLoggingStatus: BucketLoggingStatus(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketLogging.serializePutBucketLogging],
      );
      final bodyData1 = await input.body!.readData();
      final bodyStr1 = utf8.decode(bodyData1!);
      expect(bodyStr1, contains('<BucketLoggingStatus>'));
      expect(bodyStr1, contains('</BucketLoggingStatus>'));
      expect(bodyStr1, isNot(contains('<LoggingEnabled>')));

      // Test with LoggingEnabled
      input = OperationInput(operationName: 'PutBucketLogging', method: 'PUT');
      request = PutBucketLoggingRequest(
        bucketLoggingStatus: BucketLoggingStatus(
          loggingEnabled: LoggingEnabled(
            targetBucket: 'targetBucket',
            targetPrefix: 'targetPrefix',
          ),
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketLogging.serializePutBucketLogging],
      );
      final bodyData2 = await input.body!.readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(bodyStr2, contains('<LoggingEnabled>'));
      expect(bodyStr2, contains('<TargetBucket>targetBucket</TargetBucket>'));
      expect(bodyStr2, contains('<TargetPrefix>targetPrefix</TargetPrefix>'));
      expect(bodyStr2, contains('</LoggingEnabled>'));
    });

    test('testDeserializeGetBucketLogging', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketLoggingResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketLogging.deserializeGetBucketLogging],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with unexpected body - should throw
      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      result = GetBucketLoggingResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketLogging.deserializeGetBucketLogging],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<BucketLoggingStatus>
    <LoggingEnabled>
        <TargetBucket>targetBucket</TargetBucket>
        <TargetPrefix>targetPrefix</TargetPrefix>
    </LoggingEnabled>
</BucketLoggingStatus>'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketLoggingResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketLogging.deserializeGetBucketLogging],
      );

      expect(
        result.bucketLoggingStatus?.loggingEnabled?.targetBucket,
        equals('targetBucket'),
      );
      expect(
        result.bucketLoggingStatus?.loggingEnabled?.targetPrefix,
        equals('targetPrefix'),
      );
    });

    test('testSerializePutUserDefinedLogFieldsConfig', () async {
      var input = OperationInput(
        operationName: 'PutUserDefinedLogFieldsConfig',
        method: 'PUT',
      );

      // Test with empty UserDefinedLogFieldsConfiguration
      var request = PutUserDefinedLogFieldsConfigRequest(
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketLogging.serializePutUserDefinedLogFieldsConfig,
        ],
      );
      final bodyData1 = await input.body!.readData();
      final bodyStr1 = utf8.decode(bodyData1!);
      expect(bodyStr1, contains('<UserDefinedLogFieldsConfiguration>'));
      expect(bodyStr1, contains('</UserDefinedLogFieldsConfiguration>'));
      expect(bodyStr1, isNot(contains('<HeaderSet>')));
      expect(bodyStr1, isNot(contains('<ParamSet>')));

      // Test with headers and params
      input = OperationInput(
        operationName: 'PutUserDefinedLogFieldsConfig',
        method: 'PUT',
      );
      request = PutUserDefinedLogFieldsConfigRequest(
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(
          headerSet: HeaderSet(headers: ['header1', 'header2', 'header3']),
          paramSet: ParamSet(parameters: ['param1', 'param2']),
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketLogging.serializePutUserDefinedLogFieldsConfig,
        ],
      );
      final bodyData2 = await input.body!.readData();
      final bodyStr2 = utf8.decode(bodyData2!);
      expect(bodyStr2, contains('<HeaderSet>'));
      expect(bodyStr2, contains('<header>header1</header>'));
      expect(bodyStr2, contains('<header>header2</header>'));
      expect(bodyStr2, contains('<header>header3</header>'));
      expect(bodyStr2, contains('</HeaderSet>'));
      expect(bodyStr2, contains('<ParamSet>'));
      expect(bodyStr2, contains('<parameter>param1</parameter>'));
      expect(bodyStr2, contains('<parameter>param2</parameter>'));
      expect(bodyStr2, contains('</ParamSet>'));
    });

    test('testDeserializeGetUserDefinedLogFieldsConfig', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetUserDefinedLogFieldsConfigResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketLogging.deserializeGetUserDefinedLogFieldsConfig,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '''
<UserDefinedLogFieldsConfiguration>
    <HeaderSet>
        <header>header1</header>
        <header>header2</header>
        <header>header3</header>
    </HeaderSet>
    <ParamSet>
        <parameter>param1</parameter>
        <parameter>param2</parameter>
    </ParamSet>
</UserDefinedLogFieldsConfiguration>'''
              .trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetUserDefinedLogFieldsConfigResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketLogging.deserializeGetUserDefinedLogFieldsConfig,
        ],
      );

      expect(
        result.userDefinedLogFieldsConfiguration?.headerSet?.headers,
        equals(['header1', 'header2', 'header3']),
      );
      expect(
        result.userDefinedLogFieldsConfiguration?.paramSet?.parameters,
        equals(['param1', 'param2']),
      );
    });
  });
}
