import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_service.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_service.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeService Tests', () {
    test('testSerializeListBuckets - with all parameters', () async {
      var input = OperationInput(operationName: 'ListBuckets', method: 'GET');

      var request = ListBucketsRequest(
        resourceGroupId: 'rg-aek27tc****',
        prefix: 'my-',
        marker: 'mybucket',
        maxKeys: 100,
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeService.serializeListBuckets],
      );

      expect(
        input.headers['x-oss-resource-group-id'],
        equals('rg-aek27tc****'),
      );
      expect(input.parameters['prefix'], equals('my-'));
      expect(input.parameters['marker'], equals('mybucket'));
      expect(input.parameters['max-keys'], equals('100'));
    });

    test('testSerializeListBuckets - with no parameters', () async {
      var input = OperationInput(operationName: 'ListBuckets', method: 'GET');

      var request = ListBucketsRequest();

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeService.serializeListBuckets],
      );

      expect(input.headers.containsKey('x-oss-resource-group-id'), isFalse);
      expect(input.parameters.containsKey('prefix'), isFalse);
      expect(input.parameters.containsKey('marker'), isFalse);
      expect(input.parameters.containsKey('max-keys'), isFalse);
    });

    test('testSerializeListBuckets - with partial parameters', () async {
      var input = OperationInput(operationName: 'ListBuckets', method: 'GET');

      var request = ListBucketsRequest(prefix: 'test-', maxKeys: 50);

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeService.serializeListBuckets],
      );

      expect(input.headers.containsKey('x-oss-resource-group-id'), isFalse);
      expect(input.parameters['prefix'], equals('test-'));
      expect(input.parameters.containsKey('marker'), isFalse);
      expect(input.parameters['max-keys'], equals('50'));
    });

    test('testDeserializeListBuckets - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListBucketsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeService.deserializeListBuckets],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeListBuckets - unexpected body throws', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = ListBucketsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeService.deserializeListBuckets],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeListBuckets - normal response', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<ListAllMyBucketsResult>'
          '<Owner>'
          '<ID>512****</ID>'
          '<DisplayName>owner-name</DisplayName>'
          '</Owner>'
          '<Buckets>'
          '<Bucket>'
          '<Name>mybucket</Name>'
          '<Location>oss-cn-hangzhou</Location>'
          '<CreationDate>2014-02-17T18:12:43.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>Standard</StorageClass>'
          '</Bucket>'
          '</Buckets>'
          '<Prefix>my-</Prefix>'
          '<Marker></Marker>'
          '<MaxKeys>100</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '<NextMarker></NextMarker>'
          '</ListAllMyBucketsResult>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = ListBucketsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeService.deserializeListBuckets],
      );

      // Verify Owner
      expect(result.owner, isNotNull);
      expect(result.owner!.id, equals('512****'));
      expect(result.owner!.displayName, equals('owner-name'));

      // Verify pagination fields
      expect(result.prefix, equals('my-'));
      expect(result.marker, isNull);
      expect(result.maxKeys, equals(100));
      expect(result.isTruncated, equals(false));
      expect(result.nextMarker, isNull);

      // Verify Buckets
      expect(result.buckets, isNotNull);
      expect(result.buckets!.length, equals(1));

      final bucket = result.buckets![0];
      expect(bucket.name, equals('mybucket'));
      expect(bucket.location, equals('oss-cn-hangzhou'));
      expect(bucket.extranetEndpoint, equals('oss-cn-hangzhou.aliyuncs.com'));
      expect(
        bucket.intranetEndpoint,
        equals('oss-cn-hangzhou-internal.aliyuncs.com'),
      );
      expect(bucket.storageClass, equals('Standard'));
      expect(bucket.creationDate, isNotNull);
    });

    test('testDeserializeListBuckets - multiple buckets', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<ListAllMyBucketsResult>'
          '<Owner>'
          '<ID>512****</ID>'
          '<DisplayName>owner-name</DisplayName>'
          '</Owner>'
          '<Buckets>'
          '<Bucket>'
          '<Name>bucket1</Name>'
          '<Location>oss-cn-hangzhou</Location>'
          '<CreationDate>2014-02-17T18:12:43.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>Standard</StorageClass>'
          '</Bucket>'
          '<Bucket>'
          '<Name>bucket2</Name>'
          '<Location>oss-cn-shanghai</Location>'
          '<CreationDate>2015-03-20T10:30:00.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-shanghai.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-shanghai-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>IA</StorageClass>'
          '</Bucket>'
          '</Buckets>'
          '<Prefix></Prefix>'
          '<Marker></Marker>'
          '<MaxKeys>100</MaxKeys>'
          '<IsTruncated>true</IsTruncated>'
          '<NextMarker>bucket2</NextMarker>'
          '</ListAllMyBucketsResult>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = ListBucketsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeService.deserializeListBuckets],
      );

      // Verify pagination
      expect(result.isTruncated, equals(true));
      expect(result.nextMarker, equals('bucket2'));
      expect(result.maxKeys, equals(100));

      // Verify Buckets
      expect(result.buckets, isNotNull);
      expect(result.buckets!.length, equals(2));

      expect(result.buckets![0].name, equals('bucket1'));
      expect(result.buckets![0].location, equals('oss-cn-hangzhou'));
      expect(result.buckets![0].storageClass, equals('Standard'));

      expect(result.buckets![1].name, equals('bucket2'));
      expect(result.buckets![1].location, equals('oss-cn-shanghai'));
      expect(result.buckets![1].storageClass, equals('IA'));
    });
  });
}
