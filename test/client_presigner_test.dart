import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('ClientPresigner Tests', () {
    test('Public presign entry uses custom endpointProvider', () async {
      final scoped = Client(Configuration(region: 'cn-hangzhou'), [
        (o) {
          o.bucketNameResolver = (_) => 'physical';
          o.endpointProvider = (_) => 'https://alias.example/path';
        },
      ]);
      addTearDown(scoped.dispose);
      final request = GetObjectRequest(bucket: 'logical', key: 'key');
      final result = await scoped.presignGetObject(request);
      expect(result.url, 'https://alias.example/path');
      expect(request.bucket, 'logical');
      expect(request.key, 'key');
    });

    late Client client;

    setUp(() {
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          )
          .withRetryer(NopRetryer());
      client = Client(config);
    });

    // ===== presignGetObject =====
    test('testPresignGetObject - success', () async {
      final result = await client.presignGetObject(
        GetObjectRequest(bucket: 'test-bucket', key: 'test-key.txt'),
      );

      expect(result, isNotNull);
      expect(result.method, equals('GET'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('test-key.txt'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignGetObject - with expiration', () async {
      final expiration = DateTime.now().add(const Duration(hours: 1));
      final result = await client.presignGetObject(
        GetObjectRequest(bucket: 'test-bucket', key: 'test-key.txt'),
        expiration,
      );

      expect(result, isNotNull);
      expect(result.method, equals('GET'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('test-key.txt'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignGetObject - missing bucket', () async {
      expect(
        () async => await client.presignGetObject(
          GetObjectRequest(key: 'test-key.txt'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPresignGetObject - missing key', () async {
      expect(
        () async => await client.presignGetObject(
          GetObjectRequest(bucket: 'test-bucket'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignPutObject =====
    test('testPresignPutObject - success', () async {
      final result = await client.presignPutObject(
        PutObjectRequest(bucket: 'test-bucket', key: 'upload.txt'),
      );

      expect(result, isNotNull);
      expect(result.method, equals('PUT'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('upload.txt'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignPutObject - with expiration', () async {
      final expiration = DateTime.now().add(const Duration(minutes: 30));
      final result = await client.presignPutObject(
        PutObjectRequest(bucket: 'test-bucket', key: 'upload.txt'),
        expiration,
      );

      expect(result, isNotNull);
      expect(result.method, equals('PUT'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('upload.txt'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignPutObject - missing bucket', () async {
      expect(
        () async =>
            await client.presignPutObject(PutObjectRequest(key: 'upload.txt')),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPresignPutObject - missing key', () async {
      expect(
        () async => await client.presignPutObject(
          PutObjectRequest(bucket: 'test-bucket'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignHeadObject =====
    test('testPresignHeadObject - success', () async {
      final result = await client.presignHeadObject(
        HeadObjectRequest(bucket: 'test-bucket', key: 'head-key.txt'),
      );

      expect(result, isNotNull);
      expect(result.method, equals('HEAD'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('head-key.txt'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignHeadObject - missing bucket', () async {
      expect(
        () async => await client.presignHeadObject(
          HeadObjectRequest(key: 'head-key.txt'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPresignHeadObject - missing key', () async {
      expect(
        () async => await client.presignHeadObject(
          HeadObjectRequest(bucket: 'test-bucket'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignInitiateMultipartUpload =====
    test('testPresignInitiateMultipartUpload - success', () async {
      final result = await client.presignInitiateMultipartUpload(
        InitiateMultipartUploadRequest(
          bucket: 'test-bucket',
          key: 'large-file.bin',
        ),
      );

      expect(result, isNotNull);
      expect(result.method, equals('POST'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('large-file.bin'));
      expect(result.url, contains('uploads'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignInitiateMultipartUpload - missing bucket', () async {
      expect(
        () async => await client.presignInitiateMultipartUpload(
          InitiateMultipartUploadRequest(key: 'large-file.bin'),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignUploadPart =====
    test('testPresignUploadPart - success', () async {
      final result = await client.presignUploadPart(
        UploadPartRequest(
          bucket: 'test-bucket',
          key: 'large-file.bin',
          partNumber: 1,
          uploadId: 'test-upload-id',
        ),
      );

      expect(result, isNotNull);
      expect(result.method, equals('PUT'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('large-file.bin'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignUploadPart - missing bucket', () async {
      expect(
        () async => await client.presignUploadPart(
          UploadPartRequest(
            key: 'large-file.bin',
            partNumber: 1,
            uploadId: 'test-upload-id',
          ),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignCompleteMultipartUpload =====
    test('testPresignCompleteMultipartUpload - success', () async {
      final result = await client.presignCompleteMultipartUpload(
        CompleteMultipartUploadRequest(
          bucket: 'test-bucket',
          key: 'large-file.bin',
          uploadId: 'test-upload-id',
        ),
      );

      expect(result, isNotNull);
      expect(result.method, equals('POST'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('large-file.bin'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignCompleteMultipartUpload - missing bucket', () async {
      expect(
        () async => await client.presignCompleteMultipartUpload(
          CompleteMultipartUploadRequest(
            key: 'large-file.bin',
            uploadId: 'test-upload-id',
          ),
        ),
        throwsA(isA<ClientError>()),
      );
    });

    // ===== presignAbortMultipartUpload =====
    test('testPresignAbortMultipartUpload - success', () async {
      final result = await client.presignAbortMultipartUpload(
        AbortMultipartUploadRequest(
          bucket: 'test-bucket',
          key: 'large-file.bin',
          uploadId: 'test-upload-id',
        ),
      );

      expect(result, isNotNull);
      expect(result.method, equals('DELETE'));
      expect(result.url, contains('test-bucket'));
      expect(result.url, contains('large-file.bin'));
      expect(result.expiration, isNotNull);
    });

    test('testPresignAbortMultipartUpload - missing bucket', () async {
      expect(
        () async => await client.presignAbortMultipartUpload(
          AbortMultipartUploadRequest(
            key: 'large-file.bin',
            uploadId: 'test-upload-id',
          ),
        ),
        throwsA(isA<ClientError>()),
      );
    });
  });
}
