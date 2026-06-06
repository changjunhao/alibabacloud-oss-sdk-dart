import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_https_config.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_https_config.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketHttpsConfig Tests', () {
    test('testSerializePutBucketHttpsConfig', () async {
      var input = OperationInput(
        operationName: 'PutBucketHttpsConfig',
        method: 'PUT',
      );

      // Test with empty configuration
      var request = PutBucketHttpsConfigRequest(
        httpsConfiguration: HttpsConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketHttpsConfig.serializePutBucketHttpsConfig,
        ],
      );
      final emptyBody = await input.body?.readData();
      expect(emptyBody, isNotNull);
      final emptyXml = utf8.decode(emptyBody!);
      expect(emptyXml, contains('<HttpsConfiguration>'));
      expect(emptyXml, contains('</HttpsConfiguration>'));

      // Test with TLS configuration
      input = OperationInput(
        operationName: 'PutBucketHttpsConfig',
        method: 'PUT',
      );
      request = PutBucketHttpsConfigRequest(
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2', 'TLSv1.3']),
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeBucketHttpsConfig.serializePutBucketHttpsConfig,
        ],
      );
      final body = await input.body?.readData();
      expect(body, isNotNull);
      final xml = utf8.decode(body!);
      expect(xml, contains('<HttpsConfiguration>'));
      expect(xml, contains('<TLS>'));
      expect(xml, contains('<Enable>true</Enable>'));
      expect(xml, contains('<TLSVersion>TLSv1.2</TLSVersion>'));
      expect(xml, contains('<TLSVersion>TLSv1.3</TLSVersion>'));
      expect(xml, contains('</TLS>'));
      expect(xml, contains('</HttpsConfiguration>'));
    });

    test('testDeserializeGetBucketHttpsConfig', () async {
      // Test with null body - should throw
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketHttpsConfigResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketHttpsConfig.deserializeGetBucketHttpsConfig,
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
      result = GetBucketHttpsConfigResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketHttpsConfig.deserializeGetBucketHttpsConfig,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      final xml =
          '<HttpsConfiguration>'
          '<TLS>'
          '<Enable>true</Enable>'
          '<TLSVersion>TLSv1.2</TLSVersion>'
          '<TLSVersion>TLSv1.3</TLSVersion>'
          '</TLS>'
          '</HttpsConfiguration>';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketHttpsConfigResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketHttpsConfig.deserializeGetBucketHttpsConfig,
        ],
      );

      expect(result.httpsConfiguration?.tls?.enable, equals(true));
      expect(
        result.httpsConfiguration?.tls?.tlsVersions,
        equals(['TLSv1.2', 'TLSv1.3']),
      );
    });
  });
}
