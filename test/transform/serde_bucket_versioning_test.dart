import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_versioning.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_versioning.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketVersioning Tests', () {
    test('testSerializePutBucketVersioning - Enabled', () async {
      var input = OperationInput(
        operationName: 'PutBucketVersioning',
        method: 'PUT',
      );

      var request = PutBucketVersioningRequest(
        versioningConfiguration: VersioningConfiguration(status: 'Enabled'),
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketVersioning.serializePutBucketVersioning],
      );

      expect(input.body, isNotNull);
      final bodyData = await input.body!.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<VersioningConfiguration>'));
      expect(bodyStr, contains('<Status>Enabled</Status>'));
      expect(bodyStr, contains('</VersioningConfiguration>'));
    });

    test('testSerializePutBucketVersioning - Suspended', () async {
      var input = OperationInput(
        operationName: 'PutBucketVersioning',
        method: 'PUT',
      );

      var request = PutBucketVersioningRequest(
        versioningConfiguration: VersioningConfiguration(status: 'Suspended'),
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketVersioning.serializePutBucketVersioning],
      );

      expect(input.body, isNotNull);
      final bodyData = await input.body!.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<Status>Suspended</Status>'));
    });

    test('testDeserializeGetBucketVersioning - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketVersioningResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketVersioning.deserializeGetBucketVersioning,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketVersioning - normal XML', () async {
      const xml = '''
<VersioningConfiguration>
  <Status>Enabled</Status>
</VersioningConfiguration>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = GetBucketVersioningResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketVersioning.deserializeGetBucketVersioning,
        ],
      );

      expect(result.versioningConfiguration, isNotNull);
      expect(result.versioningConfiguration!.status, equals('Enabled'));
    });

    test('testSerializeListObjectVersions', () async {
      var input = OperationInput(
        operationName: 'ListObjectVersions',
        method: 'GET',
      );

      var request = ListObjectVersionsRequest(
        delimiter: '/',
        keyMarker: 'key-marker-test',
        versionIdMarker: 'version-id-marker-test',
        maxKeys: 200,
        prefix: 'test-prefix/',
        encodingType: 'url',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketVersioning.serializeListObjectVersions],
      );

      expect(input.parameters['delimiter'], equals('/'));
      expect(input.parameters['key-marker'], equals('key-marker-test'));
      expect(
        input.parameters['version-id-marker'],
        equals('version-id-marker-test'),
      );
      expect(input.parameters['max-keys'], equals('200'));
      expect(input.parameters['prefix'], equals('test-prefix/'));
      expect(input.parameters['encoding-type'], equals('url'));
    });

    test('testDeserializeListObjectVersions - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListObjectVersionsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeBucketVersioning.deserializeListObjectVersions,
          ],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeListObjectVersions - normal XML', () async {
      const xml = '''
<ListVersionsResult>
  <Name>examplebucket</Name>
  <Prefix>fun/</Prefix>
  <KeyMarker>key-marker</KeyMarker>
  <NextKeyMarker>next-key-marker</NextKeyMarker>
  <VersionIdMarker>vid-marker</VersionIdMarker>
  <NextVersionIdMarker>next-vid-marker</NextVersionIdMarker>
  <MaxKeys>100</MaxKeys>
  <Delimiter>/</Delimiter>
  <IsTruncated>true</IsTruncated>
  <Version>
    <Key>example-object-1.jpg</Key>
    <VersionId>CAEQNhiBgMDJgZCA0BYiIDc4MGZjZGI2OTBjOTRmNTE5NmU5NmFhZjhjYmY0****</VersionId>
    <IsLatest>true</IsLatest>
    <LastModified>2019-04-09T07:27:28.000Z</LastModified>
    <ETag>"250F8A0AE989679A22926A875F0A2****"</ETag>
    <Size>93731</Size>
    <StorageClass>Standard</StorageClass>
    <Owner>
      <ID>0022012****</ID>
      <DisplayName>user_example</DisplayName>
    </Owner>
  </Version>
  <Version>
    <Key>example-object-2.jpg</Key>
    <VersionId>CAEQNhiBgIC0qZCA0BYiIDcyN2RkNWJhYzM5NjRhMzQ5NjBkODY1YmE4MjAx****</VersionId>
    <IsLatest>false</IsLatest>
    <LastModified>2019-04-09T07:27:28.000Z</LastModified>
    <ETag>"3663F7B0B9D3153F884C821E7CF4****"</ETag>
    <Size>574768</Size>
    <StorageClass>IA</StorageClass>
  </Version>
  <DeleteMarker>
    <Key>example-object-3.jpg</Key>
    <VersionId>CAEQNhiBgIDW.ZCA0BYiIGM0YjE2OTczZDU5OTRmNjE5ZDhlZGM4ZTkzZjUz****</VersionId>
    <IsLatest>true</IsLatest>
    <LastModified>2019-04-09T07:27:28.000Z</LastModified>
    <Owner>
      <ID>0022012****</ID>
      <DisplayName>user_example</DisplayName>
    </Owner>
  </DeleteMarker>
  <CommonPrefixes>
    <Prefix>fun/movie/</Prefix>
  </CommonPrefixes>
</ListVersionsResult>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = ListObjectVersionsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeBucketVersioning.deserializeListObjectVersions,
        ],
      );

      expect(result.name, equals('examplebucket'));
      expect(result.prefix, equals('fun/'));
      expect(result.keyMarker, equals('key-marker'));
      expect(result.nextKeyMarker, equals('next-key-marker'));
      expect(result.versionIdMarker, equals('vid-marker'));
      expect(result.nextVersionIdMarker, equals('next-vid-marker'));
      expect(result.maxKeys, equals(100));
      expect(result.delimiter, equals('/'));
      expect(result.isTruncated, equals(true));

      // Verify Versions
      expect(result.versions, isNotNull);
      expect(result.versions!.length, equals(2));
      expect(result.versions![0].key, equals('example-object-1.jpg'));
      expect(
        result.versions![0].versionId,
        equals(
          'CAEQNhiBgMDJgZCA0BYiIDc4MGZjZGI2OTBjOTRmNTE5NmU5NmFhZjhjYmY0****',
        ),
      );
      expect(result.versions![0].isLatest, equals(true));
      expect(result.versions![0].size, equals(93731));
      expect(result.versions![0].storageClass, equals('Standard'));
      expect(
        result.versions![0].eTag,
        equals('"250F8A0AE989679A22926A875F0A2****"'),
      );
      expect(result.versions![0].owner, isNotNull);
      expect(result.versions![0].owner!.id, equals('0022012****'));
      expect(result.versions![0].owner!.displayName, equals('user_example'));
      expect(result.versions![1].key, equals('example-object-2.jpg'));
      expect(result.versions![1].isLatest, equals(false));
      expect(result.versions![1].size, equals(574768));
      expect(result.versions![1].storageClass, equals('IA'));

      // Verify DeleteMarkers
      expect(result.deleteMarkers, isNotNull);
      expect(result.deleteMarkers!.length, equals(1));
      expect(result.deleteMarkers![0].key, equals('example-object-3.jpg'));
      expect(
        result.deleteMarkers![0].versionId,
        equals(
          'CAEQNhiBgIDW.ZCA0BYiIGM0YjE2OTczZDU5OTRmNjE5ZDhlZGM4ZTkzZjUz****',
        ),
      );
      expect(result.deleteMarkers![0].isLatest, equals(true));
      expect(result.deleteMarkers![0].owner, isNotNull);
      expect(result.deleteMarkers![0].owner!.id, equals('0022012****'));
      expect(
        result.deleteMarkers![0].owner!.displayName,
        equals('user_example'),
      );

      // Verify CommonPrefixes
      expect(result.commonPrefixes, isNotNull);
      expect(result.commonPrefixes!.length, equals(1));
      expect(result.commonPrefixes![0].prefix, equals('fun/movie/'));
    });
  });
}
