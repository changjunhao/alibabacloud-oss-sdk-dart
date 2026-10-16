import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:alibabacloud_oss_sdk_dart/src/agentic/transform/serde_agentic_bucket.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';

OperationOutput xmlOutput(String? xml) => OperationOutput(
  statusCode: 200,
  headers: {'X-Oss-Request-Id': 'id'},
  body: xml == null
      ? null
      : ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
);

void main() {
  test('create configuration three states, escaping, and MD5', () async {
    for (final config in <CreateAgenticBucketConfiguration?>[
      null,
      CreateAgenticBucketConfiguration(),
      CreateAgenticBucketConfiguration(
        storageClass: 'A<&\t\n\r\u0001',
        dataRedundancyType: 'ZRS',
      ),
    ]) {
      final input = OperationInput();
      final request = CreateAgenticBucketRequest(
        createAgenticBucketConfiguration: config,
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeAgenticBucket.serializeCreateAgenticBucket,
          Serde.addContentMd5,
        ],
      );
      if (config == null) {
        expect(input.body, isNull);
        expect(input.headers['Content-MD5'], '1B2M2Y8AsgTpgAmY7PhCfg==');
      } else {
        final bytes = (await input.body!.readData())!;
        final body = utf8.decode(bytes);
        expect(
          body,
          startsWith(
            '<?xml version="1.0" encoding="UTF-8"?><CreateAgenticBucketConfiguration>',
          ),
        );
        expect(
          input.headers['Content-MD5'],
          base64Encode(md5.convert(bytes).bytes),
        );
        if (config.storageClass != null) {
          expect(body, contains('A&lt;&amp;'));
          expect(body, isNot(contains('\u0001')));
          expect(
            body,
            contains('<DataRedundancyType>ZRS</DataRedundancyType>'),
          );
        } else {
          expect(
            body,
            endsWith(
              '<CreateAgenticBucketConfiguration></CreateAgenticBucketConfiguration>',
            ),
          );
        }
      }
    }
  });

  test(
    'status XML escaping, MD5, and independent empty status transform',
    () async {
      for (final status in <String?>['Disabled', 'A<&', null]) {
        final input = OperationInput();
        final request = PutAgenticBucketStatusRequest(status: status);
        await Serde.serializeInput(
          request,
          input,
          customSerializers: [
            SerdeAgenticBucket.serializePutAgenticBucketStatus,
            Serde.addContentMd5,
          ],
        );
        if (status == null) {
          expect(input.body, isNull);
          expect(input.headers['Content-MD5'], '1B2M2Y8AsgTpgAmY7PhCfg==');
        } else {
          final data = (await input.body!.readData())!;
          expect(
            input.headers['Content-MD5'],
            base64Encode(md5.convert(data).bytes),
          );
          expect(
            utf8.decode(data),
            contains(
              '<Status>${status == 'A<&' ? 'A&lt;&amp;' : status}</Status>',
            ),
          );
        }
      }
    },
  );

  test('listing parameters exact naming and default field omission', () async {
    final basic = OperationInput();
    await SerdeAgenticBucket.serializeListAgenticBuckets(
      ListAgenticBucketsRequest(),
      basic,
    );
    expect(basic.parameters, isEmpty);
    final input = OperationInput();
    await SerdeAgenticBucket.serializeListAgenticBuckets(
      ListAgenticBucketsRequest(continuationToken: 'token', maxKeys: 10),
      input,
    );
    expect(input.parameters, {'continuation-token': 'token', 'max-keys': '10'});
    final spaces = OperationInput();
    await SerdeAgenticBucket.serializeListBucketSpaces(
      ListBucketSpacesRequest(
        prefix: 'foo',
        continuationToken: 'next',
        startAfter: 'space0',
        maxKeys: 20,
      ),
      spaces,
    );
    expect(spaces.parameters, {
      'prefix': 'foo',
      'continuation-token': 'next',
      'start-after': 'space0',
      'max-keys': '20',
    });
    expect(spaces.body, isNull);
    expect(spaces.headers['Content-MD5'], '1B2M2Y8AsgTpgAmY7PhCfg==');
  });

  for (final nested in [false, true]) {
    test('detailed model full fields and SSE nested=$nested', () async {
      const encryption =
          '<SSEAlgorithm>KMS</SSEAlgorithm><KMSMasterKeyID>key</KMSMasterKeyID><KMSDataEncryption>SM4</KMSDataEncryption>';
      final xml =
          '<AgenticBucketInfo><Name>name</Name><Owner>00137</Owner><Region>cn-hangzhou</Region>'
          '<StorageClass>Standard</StorageClass><DataRedundancyType>LRS</DataRedundancyType><Status>Enabled</Status>'
          '<BucketResourceType>agentic</BucketResourceType><CreateTime>raw-time</CreateTime><ACL>private</ACL>'
          '<PublicAccessBlock>true</PublicAccessBlock><ServerSideEncryptionRule>'
          '${nested ? '<ApplyServerSideEncryptionByDefault>$encryption</ApplyServerSideEncryptionByDefault>' : encryption}'
          '</ServerSideEncryptionRule><Versioning>Enabled</Versioning><BucketPolicy>{}</BucketPolicy><Unknown>ignored</Unknown></AgenticBucketInfo>';
      final result = GetAgenticBucketResult();
      await Serde.deserializeOutput(
        result,
        xmlOutput(xml),
        customDeserializers: [SerdeAgenticBucket.deserializeGetAgenticBucket],
      );
      expect(result.agenticBucketInfo!.toJson(), {
        'name': 'name',
        'owner': '00137',
        'region': 'cn-hangzhou',
        'storageClass': 'Standard',
        'dataRedundancyType': 'LRS',
        'status': 'Enabled',
        'bucketResourceType': 'agentic',
        'createTime': 'raw-time',
        'acl': 'private',
        'publicAccessBlock': 'true',
        'serverSideEncryptionRule': ServerSideEncryptionRule(
          sseAlgorithm: 'KMS',
          kmsMasterKeyId: 'key',
          kmsDataEncryption: 'SM4',
        ).toJson(),
        'versioning': 'Enabled',
        'bucketPolicy': '{}',
      });
      expect(result.statusCode, 200);
      expect(result.requestId, 'id');
    });
  }

  for (final count in [0, 1, 2]) {
    test('single/multiple/empty list parsing: $count', () async {
      final agentic = ListAgenticBucketsResult();
      final buckets = List.generate(
        count,
        (i) =>
            '<AgenticBucket><Name>a$i</Name><StorageClass>IA</StorageClass><DataRedundancyType>ZRS</DataRedundancyType><CreateTime>raw</CreateTime></AgenticBucket>',
      ).join();
      await SerdeAgenticBucket.deserializeListAgenticBuckets(
        agentic,
        xmlOutput(
          '<ListAgenticBucketsResult><Owner>137</Owner><Region>cn-hangzhou</Region><ContinuationToken>previous</ContinuationToken><NextContinuationToken>next</NextContinuationToken><IsTruncated>true</IsTruncated><AgenticBuckets>$buckets</AgenticBuckets></ListAgenticBucketsResult>',
        ),
      );
      expect(agentic.owner, '137');
      expect(agentic.region, 'cn-hangzhou');
      expect(agentic.continuationToken, 'previous');
      expect(agentic.nextContinuationToken, 'next');
      expect(agentic.isTruncated, isTrue);
      expect(agentic.agenticBuckets?.length ?? 0, count);
      if (count > 0) {
        expect(agentic.agenticBuckets!.last.toJson(), {
          'name': 'a${count - 1}',
          'storageClass': 'IA',
          'dataRedundancyType': 'ZRS',
          'createTime': 'raw',
        });
      }
      final spaces = ListBucketSpacesResult();
      final items = List.generate(
        count,
        (i) =>
            '<BucketSpace><Name>s$i</Name><Location>oss-cn-hangzhou</Location><CreationDate>raw</CreationDate><StorageClass>IA</StorageClass></BucketSpace>',
      ).join();
      await SerdeAgenticBucket.deserializeListBucketSpaces(
        spaces,
        xmlOutput(
          '<ListBucketSpacesResult><Owner><ID>137</ID><DisplayName>owner</DisplayName></Owner><Prefix>p</Prefix><MaxKeys>10</MaxKeys><ContinuationToken>previous</ContinuationToken><NextContinuationToken>next</NextContinuationToken><StartAfter>s0</StartAfter><IsTruncated>false</IsTruncated><BucketSpaces>$items</BucketSpaces></ListBucketSpacesResult>',
        ),
      );
      expect(spaces.owner?.id, '137');
      expect(spaces.owner?.displayName, 'owner');
      expect(spaces.prefix, 'p');
      expect(spaces.maxKeys, 10);
      expect(spaces.startAfter, 's0');
      expect(spaces.continuationToken, 'previous');
      expect(spaces.nextContinuationToken, 'next');
      expect(spaces.isTruncated, isFalse);
      expect(spaces.bucketSpaces?.length ?? 0, count);
      if (count > 0) {
        expect(spaces.bucketSpaces!.last.toJson(), {
          'name': 's${count - 1}',
          'location': 'oss-cn-hangzhou',
          'creationDate': 'raw',
          'storageClass': 'IA',
        });
      }
    });
  }

  test('missing optional container still parseable', () async {
    final result = ListAgenticBucketsResult();
    await SerdeAgenticBucket.deserializeListAgenticBuckets(
      result,
      xmlOutput(
        '<ListAgenticBucketsResult><IsTruncated>false</IsTruncated></ListAgenticBucketsResult>',
      ),
    );
    expect(result.agenticBuckets, isNull);
    final spaces = ListBucketSpacesResult();
    await SerdeAgenticBucket.deserializeListBucketSpaces(
      spaces,
      xmlOutput(
        '<ListBucketSpacesResult><IsTruncated>false</IsTruncated></ListBucketSpacesResult>',
      ),
    );
    expect(spaces.owner, isNull);
    expect(spaces.bucketSpaces, isNull);
  });

  for (final xml in <String?>[null, '<Wrong/>', '<broken']) {
    test('error or missing response body: $xml', () async {
      final matcher = throwsA(
        isA<ClientError>().having((e) => e.code, 'code', 'SerdeError'),
      );
      await expectLater(
        SerdeAgenticBucket.deserializeGetAgenticBucket(
          GetAgenticBucketResult(),
          xmlOutput(xml),
        ),
        matcher,
      );
      await expectLater(
        SerdeAgenticBucket.deserializeListAgenticBuckets(
          ListAgenticBucketsResult(),
          xmlOutput(xml),
        ),
        matcher,
      );
      await expectLater(
        SerdeAgenticBucket.deserializeListBucketSpaces(
          ListBucketSpacesResult(),
          xmlOutput(xml),
        ),
        matcher,
      );
    });
  }
}
