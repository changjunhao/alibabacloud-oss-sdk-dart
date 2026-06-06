import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientIntegrationTests', () {
    late BaseTestCase testCase;
    late Client client;

    setUp(() {
      testCase = BaseTestCase();
      client = testCase.getDefaultClient();
    });

    test('testInvokeOperationWithPutSuccess', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello world'.codeUnits);

      await testCase.createBucket(client, bucketName);

      try {
        final input = OperationInput(
          operationName: 'PutObject',
          method: 'PUT',
          bucket: bucketName,
          key: objectKey,
          headers: {'Content-Type': 'application/octet-stream'},
          body: ByteStream.fromData(content),
        );

        final output = await client.invokeOperation(input);
        expect(output.statusCode, equals(200));
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testInvokeOperationWithPutFail', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello world'.codeUnits);

      // Bucket does not exist, PUT should fail
      final input = OperationInput(
        operationName: 'PutObject',
        method: 'PUT',
        bucket: bucketName,
        key: objectKey,
        headers: {'Content-Type': 'application/octet-stream'},
        body: ByteStream.fromData(content),
      );

      await expectAsyncError(
        () => client.invokeOperation(input),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchBucket'));
        },
      );
    });

    test('testInvokeOperationWithGetSuccess', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello world'.codeUnits);

      await testCase.createBucket(client, bucketName);

      try {
        // First upload an object
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(content),
          ),
        );

        // GET via invokeOperation
        final input = OperationInput(
          operationName: 'GetObject',
          method: 'GET',
          bucket: bucketName,
          key: objectKey,
        );

        final output = await client.invokeOperation(input);
        expect(output.statusCode, equals(200));
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testInvokeOperationWithGetFail', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();

      await testCase.createBucket(client, bucketName);

      try {
        // GET non-existent object should fail
        final input = OperationInput(
          operationName: 'GetObject',
          method: 'GET',
          bucket: bucketName,
          key: objectKey,
        );

        await expectAsyncError(
          () => client.invokeOperation(input),
          errorHandler: (error) {
            expect(error, isA<ServerError>());
            final serverError = error as ServerError;
            expect(serverError.statusCode, equals(404));
            expect(serverError.code, equals('NoSuchKey'));
          },
        );
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testInvokeOperationWithHeadSuccess', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello world'.codeUnits);

      await testCase.createBucket(client, bucketName);

      try {
        // First upload an object
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(content),
          ),
        );

        // HEAD via invokeOperation
        final input = OperationInput(
          operationName: 'HeadObject',
          method: 'HEAD',
          bucket: bucketName,
          key: objectKey,
        );

        final output = await client.invokeOperation(input);
        expect(output.statusCode, equals(200));
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testInvokeOperationWithHeadFail', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();

      // HEAD on non-existent bucket should fail
      final input = OperationInput(
        operationName: 'HeadObject',
        method: 'HEAD',
        bucket: bucketName,
        key: objectKey,
      );

      await expectAsyncError(
        () => client.invokeOperation(input),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testInvokeOperationWithDeleteSuccess', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello world'.codeUnits);

      await testCase.createBucket(client, bucketName);

      try {
        // First upload an object
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(content),
          ),
        );

        // DELETE via invokeOperation
        final input = OperationInput(
          operationName: 'DeleteObject',
          method: 'DELETE',
          bucket: bucketName,
          key: objectKey,
        );

        final output = await client.invokeOperation(input);
        expect(output.statusCode, equals(204));
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testInvokeOperationWithDeleteFail', () async {
      final bucketName = testCase.randomBucketName();
      final objectKey = testCase.randomObjectName();

      // DELETE on non-existent bucket should fail
      final input = OperationInput(
        operationName: 'DeleteObject',
        method: 'DELETE',
        bucket: bucketName,
        key: objectKey,
      );

      await expectAsyncError(
        () => client.invokeOperation(input),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchBucket'));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
