import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

ResponseMessage makeXmlResponse(String xml) {
  final data = Uint8List.fromList(utf8.encode(xml));
  return ResponseMessage(
    statusCode: 200,
    headers: {'x-oss-request-id': 'req-123', 'content-type': 'application/xml'},
    content: ByteStream.fromData(data),
  );
}

void main() {
  group('ClientPaginator Tests', () {
    late MockSendRequest mock;
    late Client client;

    setUp(() {
      mock = MockSendRequest();
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          )
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
    });

    // ===== listBucketsPaginator =====
    test('testListBucketsPaginator - single page', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<ListAllMyBucketsResult>'
          '<Owner><ID>512****</ID><DisplayName>owner</DisplayName></Owner>'
          '<Buckets>'
          '<Bucket><Name>bucket1</Name><Location>oss-cn-hangzhou</Location>'
          '<CreationDate>2014-02-17T18:12:43.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>Standard</StorageClass></Bucket>'
          '</Buckets>'
          '<Prefix></Prefix><Marker></Marker>'
          '<MaxKeys>100</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '</ListAllMyBucketsResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listBucketsPaginator(ListBucketsRequest());
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].buckets!.length, 1);
      expect(results[0].buckets![0].name, 'bucket1');
      expect(mock.requests.length, 1);
    });

    test('testListBucketsPaginator - multiple pages', () async {
      final page1Xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<ListAllMyBucketsResult>'
          '<Owner><ID>512****</ID><DisplayName>owner</DisplayName></Owner>'
          '<Buckets>'
          '<Bucket><Name>bucket1</Name><Location>oss-cn-hangzhou</Location>'
          '<CreationDate>2014-02-17T18:12:43.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>Standard</StorageClass></Bucket>'
          '</Buckets>'
          '<Prefix></Prefix><Marker></Marker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>true</IsTruncated>'
          '<NextMarker>bucket1</NextMarker>'
          '</ListAllMyBucketsResult>';

      final page2Xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<ListAllMyBucketsResult>'
          '<Owner><ID>512****</ID><DisplayName>owner</DisplayName></Owner>'
          '<Buckets>'
          '<Bucket><Name>bucket2</Name><Location>oss-cn-shanghai</Location>'
          '<CreationDate>2015-03-20T10:30:00.000Z</CreationDate>'
          '<ExtranetEndpoint>oss-cn-shanghai.aliyuncs.com</ExtranetEndpoint>'
          '<IntranetEndpoint>oss-cn-shanghai-internal.aliyuncs.com</IntranetEndpoint>'
          '<StorageClass>IA</StorageClass></Bucket>'
          '</Buckets>'
          '<Prefix></Prefix><Marker>bucket1</Marker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '</ListAllMyBucketsResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listBucketsPaginator(ListBucketsRequest());
      final allBuckets = await paginator.collectAllBuckets();

      expect(allBuckets.length, 2);
      expect(allBuckets[0].name, 'bucket1');
      expect(allBuckets[1].name, 'bucket2');
      expect(mock.requests.length, 2);
    });

    // ===== listObjectsPaginator =====
    test('testListObjectsPaginator - single page', () async {
      final xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix><Marker></Marker>'
          '<MaxKeys>100</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '<Contents>'
          '<Key>obj1.txt</Key>'
          '<LastModified>2012-02-24T08:43:07.000Z</LastModified>'
          '<ETag>"5B3C1A2E053D763E1B002CC607C5A0FE1"</ETag>'
          '<Size>344606</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listObjectsPaginator(
        ListObjectsRequest(bucket: 'examplebucket'),
      );
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].contents!.length, 1);
      expect(results[0].contents![0].key, 'obj1.txt');
      expect(mock.requests.length, 1);
    });

    test('testListObjectsPaginator - multiple pages', () async {
      final page1Xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix><Marker></Marker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>true</IsTruncated>'
          '<NextMarker>obj1.txt</NextMarker>'
          '<Contents>'
          '<Key>obj1.txt</Key>'
          '<LastModified>2012-02-24T08:43:07.000Z</LastModified>'
          '<ETag>"5B3C1A2E1"</ETag>'
          '<Size>100</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      final page2Xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix><Marker>obj1.txt</Marker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '<Contents>'
          '<Key>obj2.txt</Key>'
          '<LastModified>2012-02-25T08:43:07.000Z</LastModified>'
          '<ETag>"6C4D2B3F2"</ETag>'
          '<Size>200</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listObjectsPaginator(
        ListObjectsRequest(bucket: 'examplebucket'),
      );
      final allObjects = await paginator.collectAllObjects();

      expect(allObjects.length, 2);
      expect(allObjects[0].key, 'obj1.txt');
      expect(allObjects[1].key, 'obj2.txt');
      expect(mock.requests.length, 2);
    });

    test('testListObjectsPaginator - missing bucket', () async {
      final paginator = client.listObjectsPaginator(ListObjectsRequest());

      expect(
        () async => await paginator.collectAllResults(),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== listObjectsV2Paginator =====
    test('testListObjectsV2Paginator - single page', () async {
      final xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<MaxKeys>100</MaxKeys>'
          '<KeyCount>1</KeyCount>'
          '<IsTruncated>false</IsTruncated>'
          '<Contents>'
          '<Key>v2obj1.txt</Key>'
          '<LastModified>2023-01-15T08:43:07.000Z</LastModified>'
          '<ETag>"A797938C31D59EDD"</ETag>'
          '<Size>123456</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listObjectsV2Paginator(
        ListObjectsV2Request(bucket: 'examplebucket'),
      );
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].contents!.length, 1);
      expect(results[0].contents![0].key, 'v2obj1.txt');
      expect(mock.requests.length, 1);
    });

    test('testListObjectsV2Paginator - multiple pages', () async {
      final page1Xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<MaxKeys>1</MaxKeys>'
          '<KeyCount>1</KeyCount>'
          '<IsTruncated>true</IsTruncated>'
          '<NextContinuationToken>token-page2</NextContinuationToken>'
          '<Contents>'
          '<Key>v2obj1.txt</Key>'
          '<LastModified>2023-01-15T08:43:07.000Z</LastModified>'
          '<ETag>"A1"</ETag>'
          '<Size>100</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      final page2Xml =
          '<ListBucketResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<MaxKeys>1</MaxKeys>'
          '<KeyCount>1</KeyCount>'
          '<IsTruncated>false</IsTruncated>'
          '<Contents>'
          '<Key>v2obj2.txt</Key>'
          '<LastModified>2023-01-16T08:43:07.000Z</LastModified>'
          '<ETag>"B2"</ETag>'
          '<Size>200</Size><StorageClass>Standard</StorageClass><Type>Normal</Type>'
          '</Contents>'
          '</ListBucketResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listObjectsV2Paginator(
        ListObjectsV2Request(bucket: 'examplebucket'),
      );
      final allObjects = await paginator.collectAllObjects();

      expect(allObjects.length, 2);
      expect(allObjects[0].key, 'v2obj1.txt');
      expect(allObjects[1].key, 'v2obj2.txt');
      expect(mock.requests.length, 2);
    });

    test('testListObjectsV2Paginator - missing bucket', () async {
      final paginator = client.listObjectsV2Paginator(ListObjectsV2Request());

      expect(
        () async => await paginator.collectAllResults(),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== listMultipartUploadsPaginator =====
    test('testListMultipartUploadsPaginator - single page', () async {
      final xml =
          '<ListMultipartUploadsResult>'
          '<Bucket>examplebucket</Bucket>'
          '<KeyMarker></KeyMarker>'
          '<UploadIdMarker></UploadIdMarker>'
          '<MaxUploads>1000</MaxUploads>'
          '<IsTruncated>false</IsTruncated>'
          '<Upload>'
          '<Key>multipart.data</Key>'
          '<UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>'
          '<Initiated>2012-02-23T04:18:23.000Z</Initiated>'
          '</Upload>'
          '</ListMultipartUploadsResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listMultipartUploadsPaginator(
        ListMultipartUploadsRequest(bucket: 'examplebucket'),
      );
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].uploads!.length, 1);
      expect(results[0].uploads![0].key, 'multipart.data');
      expect(mock.requests.length, 1);
    });

    test('testListMultipartUploadsPaginator - multiple pages', () async {
      final page1Xml =
          '<ListMultipartUploadsResult>'
          '<Bucket>examplebucket</Bucket>'
          '<KeyMarker></KeyMarker>'
          '<UploadIdMarker></UploadIdMarker>'
          '<NextKeyMarker>oss.avi</NextKeyMarker>'
          '<NextUploadIdMarker>0004B99B8E707874FC2D692FA5D7****</NextUploadIdMarker>'
          '<MaxUploads>1</MaxUploads>'
          '<IsTruncated>true</IsTruncated>'
          '<Upload>'
          '<Key>multipart.data</Key>'
          '<UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>'
          '<Initiated>2012-02-23T04:18:23.000Z</Initiated>'
          '</Upload>'
          '</ListMultipartUploadsResult>';

      final page2Xml =
          '<ListMultipartUploadsResult>'
          '<Bucket>examplebucket</Bucket>'
          '<KeyMarker>oss.avi</KeyMarker>'
          '<UploadIdMarker>0004B99B8E707874FC2D692FA5D7****</UploadIdMarker>'
          '<MaxUploads>1</MaxUploads>'
          '<IsTruncated>false</IsTruncated>'
          '<Upload>'
          '<Key>oss.avi</Key>'
          '<UploadId>0004B99B8E707874FC2D692FA5D7****</UploadId>'
          '<Initiated>2012-02-23T06:14:27.000Z</Initiated>'
          '</Upload>'
          '</ListMultipartUploadsResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listMultipartUploadsPaginator(
        ListMultipartUploadsRequest(bucket: 'examplebucket'),
      );
      final allUploads = await paginator.collectAllUploads();

      expect(allUploads.length, 2);
      expect(allUploads[0].key, 'multipart.data');
      expect(allUploads[1].key, 'oss.avi');
      expect(mock.requests.length, 2);
    });

    test('testListMultipartUploadsPaginator - missing bucket', () async {
      final paginator = client.listMultipartUploadsPaginator(
        ListMultipartUploadsRequest(),
      );

      expect(
        () async => await paginator.collectAllResults(),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== listObjectVersionsPaginator =====
    test('testListObjectVersionsPaginator - single page', () async {
      final xml =
          '<ListVersionsResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<KeyMarker></KeyMarker>'
          '<MaxKeys>100</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '<Version>'
          '<Key>example-object-1.jpg</Key>'
          '<VersionId>CAEQNhiBgMDJgZCA0BYi****</VersionId>'
          '<IsLatest>true</IsLatest>'
          '<LastModified>2019-04-09T07:27:28.000Z</LastModified>'
          '<ETag>"250F8A0AE989679A2****"</ETag>'
          '<Size>93731</Size>'
          '<StorageClass>Standard</StorageClass>'
          '</Version>'
          '</ListVersionsResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listObjectVersionsPaginator(
        ListObjectVersionsRequest(bucket: 'examplebucket'),
      );
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].versions!.length, 1);
      expect(results[0].versions![0].key, 'example-object-1.jpg');
      expect(mock.requests.length, 1);
    });

    test('testListObjectVersionsPaginator - multiple pages', () async {
      final page1Xml =
          '<ListVersionsResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<KeyMarker></KeyMarker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>true</IsTruncated>'
          '<NextKeyMarker>example-object-2.jpg</NextKeyMarker>'
          '<NextVersionIdMarker>CAEQNhiBgIC0qZCA0BYi****</NextVersionIdMarker>'
          '<Version>'
          '<Key>example-object-1.jpg</Key>'
          '<VersionId>CAEQNhiBgMDJgZCA0BYi****</VersionId>'
          '<IsLatest>true</IsLatest>'
          '<LastModified>2019-04-09T07:27:28.000Z</LastModified>'
          '<ETag>"250F8A0AE989679A2****"</ETag>'
          '<Size>93731</Size>'
          '<StorageClass>Standard</StorageClass>'
          '</Version>'
          '</ListVersionsResult>';

      final page2Xml =
          '<ListVersionsResult>'
          '<Name>examplebucket</Name>'
          '<Prefix></Prefix>'
          '<KeyMarker>example-object-2.jpg</KeyMarker>'
          '<MaxKeys>1</MaxKeys>'
          '<IsTruncated>false</IsTruncated>'
          '<Version>'
          '<Key>example-object-2.jpg</Key>'
          '<VersionId>CAEQNhiBgIC0qZCA0BYi****</VersionId>'
          '<IsLatest>true</IsLatest>'
          '<LastModified>2019-04-09T07:28:28.000Z</LastModified>'
          '<ETag>"3663F7B0B9D3153F884****"</ETag>'
          '<Size>574768</Size>'
          '<StorageClass>IA</StorageClass>'
          '</Version>'
          '<DeleteMarker>'
          '<Key>example-object-3.jpg</Key>'
          '<VersionId>CAEQNhiBgIDW.ZCA0BYi****</VersionId>'
          '<IsLatest>true</IsLatest>'
          '<LastModified>2019-04-09T07:27:28.000Z</LastModified>'
          '</DeleteMarker>'
          '</ListVersionsResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listObjectVersionsPaginator(
        ListObjectVersionsRequest(bucket: 'examplebucket'),
      );
      final allVersions = await paginator.collectAllVersions();
      expect(allVersions.length, 2);
      expect(allVersions[0].key, 'example-object-1.jpg');
      expect(allVersions[1].key, 'example-object-2.jpg');
      expect(mock.requests.length, 2);
    });

    test('testListObjectVersionsPaginator - missing bucket', () async {
      final paginator = client.listObjectVersionsPaginator(
        ListObjectVersionsRequest(),
      );

      expect(
        () async => await paginator.collectAllResults(),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== listPartsPaginator =====
    test('testListPartsPaginator - single page', () async {
      final xml =
          '<ListPartsResult>'
          '<Bucket>multipart-upload</Bucket>'
          '<Key>multipart.data</Key>'
          '<UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>'
          '<MaxParts>1000</MaxParts>'
          '<IsTruncated>false</IsTruncated>'
          '<Part>'
          '<PartNumber>1</PartNumber>'
          '<LastModified>2012-02-23T07:01:34.000Z</LastModified>'
          '<ETag>"3349DC700140D7F86A078****"</ETag>'
          '<Size>6291456</Size>'
          '</Part>'
          '</ListPartsResult>';

      mock.addResponse(makeXmlResponse(xml));

      final paginator = client.listPartsPaginator(
        ListPartsRequest(
          bucket: 'multipart-upload',
          key: 'multipart.data',
          uploadId: '0004B999EF518A1FE585B0C9360DC4****',
        ),
      );
      final results = await paginator.collectAllResults();

      expect(results.length, 1);
      expect(results[0].parts!.length, 1);
      expect(results[0].parts![0].partNumber, 1);
      expect(mock.requests.length, 1);
    });

    test('testListPartsPaginator - multiple pages', () async {
      final page1Xml =
          '<ListPartsResult>'
          '<Bucket>multipart-upload</Bucket>'
          '<Key>multipart.data</Key>'
          '<UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>'
          '<MaxParts>1</MaxParts>'
          '<IsTruncated>true</IsTruncated>'
          '<NextPartNumberMarker>1</NextPartNumberMarker>'
          '<Part>'
          '<PartNumber>1</PartNumber>'
          '<LastModified>2012-02-23T07:01:34.000Z</LastModified>'
          '<ETag>"3349DC700140D7F86A078****"</ETag>'
          '<Size>6291456</Size>'
          '</Part>'
          '</ListPartsResult>';

      final page2Xml =
          '<ListPartsResult>'
          '<Bucket>multipart-upload</Bucket>'
          '<Key>multipart.data</Key>'
          '<UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>'
          '<MaxParts>1</MaxParts>'
          '<IsTruncated>false</IsTruncated>'
          '<Part>'
          '<PartNumber>2</PartNumber>'
          '<LastModified>2012-02-23T07:02:34.000Z</LastModified>'
          '<ETag>"5765DC700140D7F86A078****"</ETag>'
          '<Size>6291457</Size>'
          '</Part>'
          '</ListPartsResult>';

      mock.addResponse(makeXmlResponse(page1Xml));
      mock.addResponse(makeXmlResponse(page2Xml));

      final paginator = client.listPartsPaginator(
        ListPartsRequest(
          bucket: 'multipart-upload',
          key: 'multipart.data',
          uploadId: '0004B999EF518A1FE585B0C9360DC4****',
        ),
      );
      final allParts = await paginator.collectAllParts();

      expect(allParts.length, 2);
      expect(allParts[0].partNumber, 1);
      expect(allParts[1].partNumber, 2);
      expect(mock.requests.length, 2);
    });

    test('testListPartsPaginator - missing bucket', () async {
      final paginator = client.listPartsPaginator(
        ListPartsRequest(
          key: 'multipart.data',
          uploadId: '0004B999EF518A1FE585B0C9360DC4****',
        ),
      );

      expect(
        () async => await paginator.collectAllResults(),
        throwsA(isA<ClientError>()),
      );
    });
  });
}
