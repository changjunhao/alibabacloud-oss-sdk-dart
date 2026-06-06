import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_request_payment.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_request_payment.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketRequestPayment Tests', () {
    test('testSerializePutBucketRequestPayment', () async {
      var input = OperationInput(
        operationName: 'PutBucketRequestPayment',
        method: 'PUT',
      );

      // Test with empty configuration
      var request = PutBucketRequestPaymentRequest(
        requestPaymentConfiguration: RequestPaymentConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketRequestPayment.serializePutBucketRequestPayment,
        ],
      );
      final emptyBody = await input.body?.readData();
      expect(emptyBody, isNotNull);
      final emptyXml = utf8.decode(emptyBody!);
      expect(emptyXml, contains('<RequestPaymentConfiguration>'));
      expect(emptyXml, contains('</RequestPaymentConfiguration>'));

      // Test with payer set to Requester
      input = OperationInput(
        operationName: 'PutBucketRequestPayment',
        method: 'PUT',
      );
      request = PutBucketRequestPaymentRequest(
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketRequestPayment.serializePutBucketRequestPayment,
        ],
      );
      final body = await input.body?.readData();
      expect(body, isNotNull);
      final xml = utf8.decode(body!);
      expect(xml, contains('<Payer>Requester</Payer>'));
      expect(xml, contains('<RequestPaymentConfiguration>'));
      expect(xml, contains('</RequestPaymentConfiguration>'));
    });

    test('testDeserializeGetBucketRequestPayment', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketRequestPaymentResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketRequestPayment.deserializeGetBucketRequestPayment,
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
      result = GetBucketRequestPaymentResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketRequestPayment.deserializeGetBucketRequestPayment,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '<RequestPaymentConfiguration>'
          '<Payer>Requester</Payer>'
          '</RequestPaymentConfiguration>';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketRequestPaymentResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketRequestPayment.deserializeGetBucketRequestPayment,
        ],
      );

      expect(result.requestPaymentConfiguration?.payer, equals('Requester'));
    });
  });
}
