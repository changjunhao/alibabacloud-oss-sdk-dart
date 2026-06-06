import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_basic.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_basic.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketBasic Tests', () {
    test('testSerializePutBucket - empty request', () async {
      var input = OperationInput(operationName: 'PutBucket', method: 'PUT');

      var request = PutBucketRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketBasic.serializePutBucket],
      );

      expect(input.headers['x-oss-acl'], isNull);
      expect(input.headers['x-oss-resource-group-id'], isNull);
      // Body should still contain CreateBucketConfiguration (empty)
      expect(input.body, isNotNull);
    });

    test('testSerializePutBucket - with ACL and resourceGroupId', () async {
      var input = OperationInput(operationName: 'PutBucket', method: 'PUT');

      var request = PutBucketRequest(
        acl: 'private',
        resourceGroupId: 'rg-aek27tc****',
        createBucketConfiguration: CreateBucketConfiguration(
          storageClass: 'Standard',
          dataRedundancyType: 'LRS',
        ),
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketBasic.serializePutBucket],
      );

      expect(input.headers['x-oss-acl'], equals('private'));
      expect(
        input.headers['x-oss-resource-group-id'],
        equals('rg-aek27tc****'),
      );

      // Verify body contains CreateBucketConfiguration XML
      expect(input.body, isNotNull);
      final bodyData = await input.body!.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(bodyStr, contains('<StorageClass>Standard</StorageClass>'));
      expect(bodyStr, contains('<DataRedundancyType>LRS</DataRedundancyType>'));
      expect(bodyStr, contains('<CreateBucketConfiguration>'));
    });

    test('testDeserializeGetBucketStat - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketStatResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketBasic.deserializeGetBucketStat],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketStat - normal XML', () async {
      const xml = '''
<BucketStat>
  <Storage>1600</Storage>
  <ObjectCount>230</ObjectCount>
  <MultipartUploadCount>40</MultipartUploadCount>
  <LiveChannelCount>4</LiveChannelCount>
  <LastModifiedTime>1643341269</LastModifiedTime>
  <StandardStorage>430</StandardStorage>
  <StandardObjectCount>China66</StandardObjectCount>
  <InfrequentAccessStorage>2359296</InfrequentAccessStorage>
  <InfrequentAccessRealStorage>360</InfrequentAccessRealStorage>
  <InfrequentAccessObjectCount>China Chinese</InfrequentAccessObjectCount>
  <ArchiveStorage>2949120</ArchiveStorage>
  <ArchiveRealStorage>450</ArchiveRealStorage>
  <ArchiveObjectCount>China object</ArchiveObjectCount>
  <ColdArchiveStorage>China</ColdArchiveStorage>
  <ColdArchiveRealStorage>China</ColdArchiveRealStorage>
  <ColdArchiveObjectCount>China</ColdArchiveObjectCount>
  <DeepColdArchiveStorage>China</DeepColdArchiveStorage>
  <DeepColdArchiveRealStorage>China</DeepColdArchiveRealStorage>
  <DeepColdArchiveObjectCount>China</DeepColdArchiveObjectCount>
  <DeleteMarkerCount>China</DeleteMarkerCount>
  <MultipartPartCount>China</MultipartPartCount>
</BucketStat>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = GetBucketStatResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketBasic.deserializeGetBucketStat],
      );

      expect(result.bucketStat, isNotNull);
      expect(result.bucketStat!.storage, equals(1600));
      expect(result.bucketStat!.objectCount, equals(230));
      expect(result.bucketStat!.multipartUploadCount, equals(40));
      expect(result.bucketStat!.liveChannelCount, equals(4));
      expect(result.bucketStat!.lastModifiedTime, equals(1643341269));
      expect(result.bucketStat!.standardStorage, equals(430));
      expect(result.bucketStat!.infrequentAccessStorage, equals(2359296));
      expect(result.bucketStat!.infrequentAccessRealStorage, equals(360));
      expect(result.bucketStat!.archiveStorage, equals(2949120));
      expect(result.bucketStat!.archiveRealStorage, equals(450));
    });

    test('testSerializeListObjects', () async {
      var input = OperationInput(operationName: 'ListObjects', method: 'GET');

      var request = ListObjectsRequest(
        delimiter: '/',
        marker: 'marker-test',
        maxKeys: 100,
        prefix: 'fun/',
        encodingType: 'url',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketBasic.serializeListObjects],
      );

      expect(input.parameters['delimiter'], equals('/'));
      expect(input.parameters['marker'], equals('marker-test'));
      expect(input.parameters['max-keys'], equals('100'));
      expect(input.parameters['prefix'], equals('fun/'));
      expect(input.parameters['encoding-type'], equals('url'));
    });

    test('testDeserializeListObjects - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListObjectsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketBasic.deserializeListObjects],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeListObjects - normal XML', () async {
      const xml = '''
<ListBucketResult>
  <Name>examplebucket</Name>
  <Prefix></Prefix>
  <Marker></Marker>
  <MaxKeys>100</MaxKeys>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>fun/movie/001.avi</Key>
    <LastModified>2012-02-24T08:43:07.000Z</LastModified>
    <ETag>"5B3C1A2E053D763E1B002CC607C5A0FE1"</ETag>
    <Size>344606</Size>
    <StorageClass>Standard</StorageClass>
    <Type>Normal</Type>
    <Owner>
      <ID>0022012****</ID>
      <DisplayName>user_example</DisplayName>
    </Owner>
  </Contents>
  <Contents>
    <Key>fun/movie/007.avi</Key>
    <LastModified>2012-02-24T08:45:07.000Z</LastModified>
    <ETag>"5B3C1A2E053D763E1B002CC607C5A0FE2"</ETag>
    <Size>244606</Size>
    <StorageClass>Standard</StorageClass>
    <Type>Normal</Type>
  </Contents>
  <CommonPrefixes>
    <Prefix>fun/movie/</Prefix>
  </CommonPrefixes>
</ListBucketResult>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = ListObjectsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketBasic.deserializeListObjects],
      );

      expect(result.name, equals('examplebucket'));
      expect(result.maxKeys, equals(100));
      expect(result.isTruncated, equals(false));
      expect(result.contents, isNotNull);
      expect(result.contents!.length, equals(2));
      expect(result.contents![0].key, equals('fun/movie/001.avi'));
      expect(result.contents![0].size, equals(344606));
      expect(result.contents![0].storageClass, equals('Standard'));
      expect(result.contents![0].type, equals('Normal'));
      expect(
        result.contents![0].etag,
        equals('"5B3C1A2E053D763E1B002CC607C5A0FE1"'),
      );
      expect(result.contents![0].owner, isNotNull);
      expect(result.contents![0].owner!.id, equals('0022012****'));
      expect(result.contents![0].owner!.displayName, equals('user_example'));
      expect(result.contents![1].key, equals('fun/movie/007.avi'));
      expect(result.contents![1].size, equals(244606));
      expect(result.commonPrefixes, isNotNull);
      expect(result.commonPrefixes!.length, equals(1));
      expect(result.commonPrefixes![0].prefix, equals('fun/movie/'));
    });

    test('testSerializeListObjectsV2', () async {
      var input = OperationInput(operationName: 'ListObjectsV2', method: 'GET');

      var request = ListObjectsV2Request(
        delimiter: '/',
        maxKeys: 50,
        prefix: 'test/',
        encodingType: 'url',
        fetchOwner: true,
        startAfter: 'start-object',
        continuationToken: 'token-123',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketBasic.serializeListObjectsV2],
      );

      expect(input.parameters['delimiter'], equals('/'));
      expect(input.parameters['max-keys'], equals('50'));
      expect(input.parameters['prefix'], equals('test/'));
      expect(input.parameters['encoding-type'], equals('url'));
      expect(input.parameters['fetch-owner'], equals('true'));
      expect(input.parameters['start-after'], equals('start-object'));
      expect(input.parameters['continuation-token'], equals('token-123'));
    });

    test('testDeserializeListObjectsV2 - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListObjectsV2Result();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketBasic.deserializeListObjectsV2],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeListObjectsV2 - normal XML', () async {
      const xml = '''
<ListBucketResult>
  <Name>examplebucket</Name>
  <Prefix>fun/</Prefix>
  <MaxKeys>100</MaxKeys>
  <KeyCount>3</KeyCount>
  <IsTruncated>true</IsTruncated>
  <StartAfter>start-obj</StartAfter>
  <ContinuationToken>token-123</ContinuationToken>
  <NextContinuationToken>next-token-456</NextContinuationToken>
  <Delimiter>/</Delimiter>
  <Contents>
    <Key>fun/test.jpg</Key>
    <LastModified>2023-01-15T08:43:07.000Z</LastModified>
    <ETag>"A797938C31D59EDD08D86188F6D5B"</ETag>
    <Size>123456</Size>
    <StorageClass>Standard</StorageClass>
    <Type>Normal</Type>
    <Owner>
      <ID>owner-id-123</ID>
      <DisplayName>owner_name</DisplayName>
    </Owner>
  </Contents>
  <CommonPrefixes>
    <Prefix>fun/movie/</Prefix>
  </CommonPrefixes>
</ListBucketResult>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = ListObjectsV2Result();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketBasic.deserializeListObjectsV2],
      );

      expect(result.name, equals('examplebucket'));
      expect(result.prefix, equals('fun/'));
      expect(result.maxKeys, equals(100));
      expect(result.keyCount, equals(3));
      expect(result.isTruncated, equals(true));
      expect(result.startAfter, equals('start-obj'));
      expect(result.continuationToken, equals('token-123'));
      expect(result.nextContinuationToken, equals('next-token-456'));
      expect(result.delimiter, equals('/'));
      expect(result.contents, isNotNull);
      expect(result.contents!.length, equals(1));
      expect(result.contents![0].key, equals('fun/test.jpg'));
      expect(result.contents![0].size, equals(123456));
      expect(result.contents![0].storageClass, equals('Standard'));
      expect(result.contents![0].owner, isNotNull);
      expect(result.contents![0].owner!.id, equals('owner-id-123'));
      expect(result.contents![0].owner!.displayName, equals('owner_name'));
      expect(result.commonPrefixes, isNotNull);
      expect(result.commonPrefixes!.length, equals(1));
      expect(result.commonPrefixes![0].prefix, equals('fun/movie/'));
    });

    test('testDeserializeGetBucketInfo - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketInfoResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketBasic.deserializeGetBucketInfo],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketInfo - normal XML', () async {
      const xml = '''
<BucketInfo>
  <Bucket>
    <CreationDate>2013-07-31T10:56:21.000Z</CreationDate>
    <ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>
    <IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>
    <Location>oss-cn-hangzhou</Location>
    <StorageClass>Standard</StorageClass>
    <TransferAcceleration>Disabled</TransferAcceleration>
    <CrossRegionReplication>Disabled</CrossRegionReplication>
    <DataRedundancyType>LRS</DataRedundancyType>
    <Name>oss-example</Name>
    <ResourceGroupId>rg-aek27tc****</ResourceGroupId>
    <Versioning>Enabled</Versioning>
    <AccessMonitor>Enabled</AccessMonitor>
    <Comment>test bucket</Comment>
    <BlockPublicAccess>true</BlockPublicAccess>
    <Owner>
      <DisplayName>username</DisplayName>
      <ID>27183473914****</ID>
    </Owner>
    <AccessControlList>
      <Grant>private</Grant>
    </AccessControlList>
    <ServerSideEncryptionRule>
      <SSEAlgorithm>KMS</SSEAlgorithm>
      <KMSMasterKeyID>key-id-123</KMSMasterKeyID>
      <KMSDataEncryption>SM4</KMSDataEncryption>
    </ServerSideEncryptionRule>
    <BucketPolicy>
      <LogBucket>log-bucket</LogBucket>
      <LogPrefix>log-prefix/</LogPrefix>
    </BucketPolicy>
  </Bucket>
</BucketInfo>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = GetBucketInfoResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketBasic.deserializeGetBucketInfo],
      );

      expect(result.bucketInfo, isNotNull);
      final bucket = result.bucketInfo!.bucket;
      expect(bucket, isNotNull);
      expect(bucket!.name, equals('oss-example'));
      expect(bucket.location, equals('oss-cn-hangzhou'));
      expect(bucket.storageClass, equals('Standard'));
      expect(bucket.extranetEndpoint, equals('oss-cn-hangzhou.aliyuncs.com'));
      expect(
        bucket.intranetEndpoint,
        equals('oss-cn-hangzhou-internal.aliyuncs.com'),
      );
      expect(bucket.transferAcceleration, equals('Disabled'));
      expect(bucket.crossRegionReplication, equals('Disabled'));
      expect(bucket.dataRedundancyType, equals('LRS'));
      expect(bucket.resourceGroupId, equals('rg-aek27tc****'));
      expect(bucket.versioning, equals('Enabled'));
      expect(bucket.accessMonitor, equals('Enabled'));
      expect(bucket.comment, equals('test bucket'));
      expect(bucket.blockPublicAccess, equals(true));
      expect(bucket.owner, isNotNull);
      expect(bucket.owner!.displayName, equals('username'));
      expect(bucket.owner!.id, equals('27183473914****'));
      expect(bucket.accessControlList, isNotNull);
      expect(bucket.accessControlList!.grant, equals('private'));
      expect(bucket.serverSideEncryptionRule, isNotNull);
      expect(bucket.serverSideEncryptionRule!.sseAlgorithm, equals('KMS'));
      expect(
        bucket.serverSideEncryptionRule!.kmsMasterKeyId,
        equals('key-id-123'),
      );
      expect(bucket.serverSideEncryptionRule!.kmsDataEncryption, equals('SM4'));
      expect(bucket.bucketPolicy, isNotNull);
      expect(bucket.bucketPolicy!.logBucket, equals('log-bucket'));
      expect(bucket.bucketPolicy!.logPrefix, equals('log-prefix/'));
    });

    test('testDeserializeGetBucketLocation - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketLocationResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketBasic.deserializeGetBucketLocation],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketLocation - normal XML', () async {
      const xml = '''
<LocationConstraint>oss-cn-hangzhou</LocationConstraint>
''';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml.trim()))),
      );
      var result = GetBucketLocationResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketBasic.deserializeGetBucketLocation],
      );

      expect(result.locationConstraint, equals('oss-cn-hangzhou'));
    });
  });
}
