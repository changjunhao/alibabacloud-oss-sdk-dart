import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientPresignerTests', () {
    late BaseTestCase testCase;
    late Client client;
    late String bucketName;

    setUp(() async {
      testCase = BaseTestCase();
      client = testCase.getDefaultClient();
      bucketName = testCase.randomBucketName();
      await testCase.createBucket(client, bucketName);
    });

    tearDown(() async {
      await testCase.cleanBucket(client, bucketName);
    });

    test('testPresignPutObject', () async {
      final key = testCase.randomObjectName();

      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final request = PutObjectRequest(bucket: bucketName, key: key);
      final result = await client.presignPutObject(request, expiration);

      // Verify presign result
      expect(result.method, equals('PUT'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to upload data
      final content = utf8.encode('hello oss');
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        httpRequest.add(content);
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignGetObject', () async {
      final key = testCase.randomObjectName();
      final content = utf8.encode('hello oss');

      // First upload an object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: key,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await client.putObject(putRequest);

      // Generate presigned GET URL
      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final getRequest = GetObjectRequest(bucket: bucketName, key: key);
      final result = await client.presignGetObject(getRequest, expiration);

      // Verify presign result
      expect(result.method, equals('GET'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to download data
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));

        final body = await response.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        expect(body, equals(content));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignHeadObject', () async {
      final key = testCase.randomObjectName();
      final content = utf8.encode('hello oss');

      // First upload an object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: key,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await client.putObject(putRequest);

      // Generate presigned HEAD URL
      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final headRequest = HeadObjectRequest(bucket: bucketName, key: key);
      final result = await client.presignHeadObject(headRequest, expiration);

      // Verify presign result
      expect(result.method, equals('HEAD'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to send HEAD request
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignInitiateMultipartUpload', () async {
      final key = testCase.randomObjectName();

      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final request = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final result = await client.presignInitiateMultipartUpload(
        request,
        expiration,
      );

      // Verify presign result
      expect(result.method, equals('POST'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.url, contains('uploads'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to initiate multipart upload
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignUploadPart', () async {
      final key = testCase.randomObjectName();

      // Initiate multipart upload first
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      final uploadId = initResult.uploadId!;

      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final request = UploadPartRequest(
        bucket: bucketName,
        key: key,
        partNumber: 1,
        uploadId: uploadId,
      );
      final result = await client.presignUploadPart(request, expiration);

      // Verify presign result
      expect(result.method, equals('PUT'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.url, contains('uploadId'));
      expect(result.url, contains('partNumber'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to upload a part
      final content = utf8.encode('hello oss');
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        httpRequest.add(content);
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignCompleteMultipartUpload', () async {
      final key = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      final uploadId = initResult.uploadId!;

      // Upload a part
      final content = utf8.encode('hello oss');
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: key,
        partNumber: 1,
        uploadId: uploadId,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await client.uploadPart(uploadPartRequest);

      // Generate presigned CompleteMultipartUpload URL
      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final request = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: key,
        uploadId: uploadId,
        completeAll: 'yes',
      );
      final result = await client.presignCompleteMultipartUpload(
        request,
        expiration,
      );

      // Verify presign result
      expect(result.method, equals('POST'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.url, contains('uploadId'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to complete multipart upload
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        final response = await httpRequest.close();
        expect(response.statusCode, equals(200));
      } finally {
        httpClient.close();
      }
    });

    test('testPresignAbortMultipartUpload', () async {
      final key = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      final uploadId = initResult.uploadId!;

      // Upload a part
      final content = utf8.encode('hello oss');
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: key,
        partNumber: 1,
        uploadId: uploadId,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await client.uploadPart(uploadPartRequest);

      // Generate presigned AbortMultipartUpload URL
      final expiration = DateTime.now().add(const Duration(minutes: 10));
      final request = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: key,
        uploadId: uploadId,
      );
      final result = await client.presignAbortMultipartUpload(
        request,
        expiration,
      );

      // Verify presign result
      expect(result.method, equals('DELETE'));
      expect(result.url, contains('x-oss-signature-version'));
      expect(result.url, contains('x-oss-expires'));
      expect(result.url, contains('x-oss-credential'));
      expect(result.url, contains('x-oss-signature'));
      expect(result.url, contains('uploadId'));
      expect(result.expiration, equals(expiration));

      // Use the presigned URL to abort multipart upload
      final httpClient = HttpClient();
      try {
        final uri = Uri.parse(result.url);
        final httpRequest = await httpClient.openUrl(result.method, uri);
        if (result.signedHeaders != null) {
          result.signedHeaders!.forEach((key, value) {
            httpRequest.headers.set(key, value);
          });
        }
        final response = await httpRequest.close();
        expect(response.statusCode, equals(204));
      } finally {
        httpClient.close();
      }
    });
  }, skip: BaseTestCase.skipReason);
}
