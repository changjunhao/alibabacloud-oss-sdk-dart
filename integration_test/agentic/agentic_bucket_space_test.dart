import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'agentic_test_support.dart';

void main() {
  group('BucketSpace reuses regular OSS operations', () {
    late AgenticTestSupport support;
    setUp(() {
      support = AgenticTestSupport();
    });
    tearDown(() => support.cleanup());

    test(
      'create binding, info, ACL, object CRUD, listing, and presign',
      () async {
        final parent = await support.createBucketFixture();
        final space = await support.createSpaceFixture(parent);
        final client = support.spaces;
        final info = await client.getBucketInfo(
          GetBucketInfoRequest(bucket: space),
        );
        expect(
          info.bucketInfo?.bucket?.agenticBucketName,
          support.fullBucketName(parent),
        );
        expect(
          info.bucketInfo?.bucket?.bucketResourceType,
          'AgenticBucketSpace',
        );
        final acl = await client.getBucketAcl(
          GetBucketAclRequest(bucket: space),
        );
        expect(acl.accessControlPolicy?.accessControlList?.grant, 'private');
        final key = support.randomObjectName();
        support.trackObject(space, key);
        final data = Uint8List.fromList(utf8.encode('hello agentic'));
        expect(
          (await client.putObject(
            PutObjectRequest(
              bucket: space,
              key: key,
              body: ByteStream.fromData(data),
            ),
          )).statusCode,
          200,
        );
        expect(
          (await client.headObject(
            HeadObjectRequest(bucket: space, key: key),
          )).statusCode,
          200,
        );
        final get = await client.getObject(
          GetObjectRequest(bucket: space, key: key),
        );
        expect(await get.body!.readData(), data);
        final list = await client.listObjectsV2(
          ListObjectsV2Request(bucket: space),
        );
        expect(list.contents?.map((v) => v.key), contains(key));
        final pages = await support.agentic
            .listBucketSpacesPaginator(
              ListBucketSpacesRequest(bucket: parent),
              paginatorOptions: PaginatorOptions(limit: 1),
            )
            .collectAllResults();
        expect(
          pages
              .expand((p) => p.bucketSpaces ?? <BucketSpaceSummary>[])
              .map((v) => v.name),
          contains(support.fullSpaceName(space)),
        );

        final signed = await client.presignGetObject(
          GetObjectRequest(bucket: space, key: key),
        );
        final http = HttpClient();
        try {
          final request = await http.getUrl(Uri.parse(signed.url));
          final response = await request.close();
          expect(response.statusCode, 200);
          expect(
            await response.transform(utf8.decoder).join(),
            'hello agentic',
          );
        } finally {
          http.close(force: true);
        }
        expect(
          (await client.deleteObject(
            DeleteObjectRequest(bucket: space, key: key),
          )).statusCode,
          204,
        );
      },
    );
  }, skip: AgenticTestSupport.agenticSkipReason);
}
