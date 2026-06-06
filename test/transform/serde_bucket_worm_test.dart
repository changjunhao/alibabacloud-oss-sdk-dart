import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_worm.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_enums.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_worm.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketWorm Tests', () {
    test('testSerializeInitiateBucketWorm - empty config', () async {
      final input = OperationInput(
        operationName: 'InitiateBucketWorm',
        method: 'POST',
      );

      final request = InitiateBucketWormRequest(
        initiateWormConfiguration: InitiateWormConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketWorm.serializeInitiateBucketWorm],
      );

      final bodyData = await input.body?.readData();
      final bodyString = utf8.decode(bodyData!);
      expect(
        bodyString,
        equals('<InitiateWormConfiguration></InitiateWormConfiguration>'),
      );
    });

    test(
      'testSerializeInitiateBucketWorm - with retentionPeriodInDays',
      () async {
        final input = OperationInput(
          operationName: 'InitiateBucketWorm',
          method: 'POST',
        );

        final request = InitiateBucketWormRequest(
          initiateWormConfiguration: InitiateWormConfiguration(
            retentionPeriodInDays: 1,
          ),
        );
        await Serde.serializeInput(
          request,
          input,
          customSerializers: [SerdeBucketWorm.serializeInitiateBucketWorm],
        );

        final bodyData = await input.body?.readData();
        final bodyString = utf8.decode(bodyData!);
        expect(
          bodyString,
          equals(
            '<InitiateWormConfiguration>'
            '<RetentionPeriodInDays>1</RetentionPeriodInDays>'
            '</InitiateWormConfiguration>',
          ),
        );
      },
    );

    test('testSerializeCompleteBucketWorm - no wormId', () async {
      final input = OperationInput(
        operationName: 'CompleteBucketWorm',
        method: 'POST',
      );

      final request = CompleteBucketWormRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketWorm.serializeCompleteBucketWorm],
      );
      expect(input.parameters['wormId'], isNull);
    });

    test('testSerializeCompleteBucketWorm - with wormId', () async {
      final input = OperationInput(
        operationName: 'CompleteBucketWorm',
        method: 'POST',
      );

      final request = CompleteBucketWormRequest(wormId: 'wormId');
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketWorm.serializeCompleteBucketWorm],
      );
      expect(input.parameters['wormId'], equals('wormId'));
    });

    test('testSerializeExtendBucketWorm - empty config', () async {
      final input = OperationInput(
        operationName: 'ExtendBucketWorm',
        method: 'POST',
      );

      final request = ExtendBucketWormRequest(
        extendWormConfiguration: ExtendWormConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketWorm.serializeExtendBucketWorm],
      );

      final bodyData = await input.body?.readData();
      final bodyString = utf8.decode(bodyData!);
      expect(
        bodyString,
        equals('<ExtendWormConfiguration></ExtendWormConfiguration>'),
      );
      expect(input.parameters['wormId'], isNull);
    });

    test(
      'testSerializeExtendBucketWorm - with wormId and retentionPeriodInDays',
      () async {
        final input = OperationInput(
          operationName: 'ExtendBucketWorm',
          method: 'POST',
        );

        final request = ExtendBucketWormRequest(
          wormId: 'wormId',
          extendWormConfiguration: ExtendWormConfiguration(
            retentionPeriodInDays: 1,
          ),
        );
        await Serde.serializeInput(
          request,
          input,
          customSerializers: [SerdeBucketWorm.serializeExtendBucketWorm],
        );

        final bodyData = await input.body?.readData();
        final bodyString = utf8.decode(bodyData!);
        expect(
          bodyString,
          equals(
            '<ExtendWormConfiguration>'
            '<RetentionPeriodInDays>1</RetentionPeriodInDays>'
            '</ExtendWormConfiguration>',
          ),
        );
        expect(input.parameters['wormId'], equals('wormId'));
      },
    );

    test('testDeserializeGetBucketWorm - null body throws error', () async {
      final output = OperationOutput(statusCode: 200, headers: {});
      final result = GetBucketWormResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketWorm.deserializeGetBucketWorm],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketWorm - normal response', () async {
      final xml =
          '<WormConfiguration>'
          '<WormId>1666E2CFB2B3418****</WormId>'
          '<State>Locked</State>'
          '<RetentionPeriodInDays>1</RetentionPeriodInDays>'
          '<CreationDate>2020-10-15T15:50:32</CreationDate>'
          '<ExpirationDate>2021-10-15T15:50:32</ExpirationDate>'
          '</WormConfiguration>';

      final output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      final result = GetBucketWormResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketWorm.deserializeGetBucketWorm],
      );

      expect(result.wormConfiguration?.wormId, equals('1666E2CFB2B3418****'));
      expect(result.wormConfiguration?.state, equals(WormState.locked));
      expect(result.wormConfiguration?.retentionPeriodInDays, equals(1));
      expect(
        result.wormConfiguration?.creationDate,
        equals('2020-10-15T15:50:32'),
      );
      expect(
        result.wormConfiguration?.expirationDate,
        equals('2021-10-15T15:50:32'),
      );
    });

    test(
      'testDeserializeGetBucketWorm - unexpected body throws error',
      () async {
        final output = OperationOutput(
          statusCode: 200,
          headers: {},
          body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
        );
        final result = GetBucketWormResult();

        expect(
          () async => await Serde.deserializeOutput(
            result,
            output,
            customDeserializers: [SerdeBucketWorm.deserializeGetBucketWorm],
          ),
          throwsA(isA<ClientError>()),
        );
      },
    );

    test('testInitiateBucketWormResult - wormId from headers', () {
      final result = InitiateBucketWormResult();
      result.commonProp.headers = {'x-oss-worm-id': 'test-worm-id-123'};
      expect(result.wormId, equals('test-worm-id-123'));
    });

    test(
      'testInitiateBucketWormResult - wormId is null when header missing',
      () {
        final result = InitiateBucketWormResult();
        result.commonProp.headers = {};
        expect(result.wormId, isNull);
      },
    );
  });
}
