import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketCorsTests', () {
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

    test('testPutBucketCors', () async {
      final corsRules = [
        CORSRule(
          allowedOrigins: ['www.aliyun.com', 'www.test.com'],
          allowedMethods: ['PUT', 'GET'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test', 'x-oss-test1'],
          maxAgeSeconds: 10000,
        ),
        CORSRule(
          allowedOrigins: ['www.aliyun1.com', 'www.test1.com'],
          allowedMethods: ['DELETE', 'HEAD'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test1', 'x-oss-test11'],
          maxAgeSeconds: 20000,
        ),
      ];

      final corsConfig = CORSConfiguration(corsRules: corsRules);
      final request = PutBucketCorsRequest(
        bucket: bucketName,
        corsConfiguration: corsConfig,
      );
      final result = await expectNoAsyncError(
        () => client.putBucketCors(request),
      );
      expect(result.commonProp.statusCode, 200);
    });

    test('testGetBucketCors', () async {
      final corsRules = [
        CORSRule(
          allowedOrigins: ['www.aliyun.com', 'www.test.com'],
          allowedMethods: ['PUT', 'GET'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test', 'x-oss-test1'],
          maxAgeSeconds: 10000,
        ),
        CORSRule(
          allowedOrigins: ['www.aliyun1.com', 'www.test1.com'],
          allowedMethods: ['DELETE', 'HEAD'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test1', 'x-oss-test11'],
          maxAgeSeconds: 20000,
        ),
      ];

      final corsConfig = CORSConfiguration(corsRules: corsRules);
      final putRequest = PutBucketCorsRequest(
        bucket: bucketName,
        corsConfiguration: corsConfig,
      );
      await expectNoAsyncError(() => client.putBucketCors(putRequest));

      final getRequest = GetBucketCorsRequest(bucket: bucketName);
      final getResult = await expectNoAsyncError(
        () => client.getBucketCors(getRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      expect(getResult.corsConfiguration?.corsRules?.length, 2);
    });

    test('testDeleteBucketCors', () async {
      final corsRules = [
        CORSRule(
          allowedOrigins: ['www.aliyun.com', 'www.test.com'],
          allowedMethods: ['PUT', 'GET'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test', 'x-oss-test1'],
          maxAgeSeconds: 10000,
        ),
      ];

      final corsConfig = CORSConfiguration(corsRules: corsRules);
      final putRequest = PutBucketCorsRequest(
        bucket: bucketName,
        corsConfiguration: corsConfig,
      );
      await expectNoAsyncError(() => client.putBucketCors(putRequest));

      final deleteRequest = DeleteBucketCorsRequest(bucket: bucketName);
      final deleteResult = await expectNoAsyncError(
        () => client.deleteBucketCors(deleteRequest),
      );
      expect(deleteResult.commonProp.statusCode, 204);

      // Verify CORS configuration is deleted
      await expectAsyncError(
        () => client.getBucketCors(GetBucketCorsRequest(bucket: bucketName)),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testPutBucketCorsFail', () async {
      // Missing corsConfiguration
      final request = PutBucketCorsRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.putBucketCors(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('request.corsConfiguration'));
        },
      );

      // Invalid CORS rule (missing allowedMethods)
      final invalidRequest = PutBucketCorsRequest(
        bucket: bucketName,
        corsConfiguration: CORSConfiguration(
          corsRules: [
            CORSRule(allowedOrigins: ['a']),
          ],
        ),
      );
      await expectAsyncError(
        () => client.putBucketCors(invalidRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('MalformedXML'));
        },
      );
    });

    test('testGetBucketCorsFail', () async {
      // CORS not configured, should return 404
      final request = GetBucketCorsRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.getBucketCors(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchCORSConfiguration'));
        },
      );
    });

    test('testDeleteBucketCorsFail', () async {
      // Non-existent bucket
      final bucket = testCase.randomBucketName();
      final request = DeleteBucketCorsRequest(bucket: bucket);
      await expectAsyncError(
        () => client.deleteBucketCors(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testOptionObject', () async {
      // Set up CORS rules first
      final corsRules = [
        CORSRule(
          allowedOrigins: ['http://www.example.com'],
          allowedMethods: ['PUT', 'GET'],
          allowedHeaders: ['authorization'],
          exposeHeaders: ['x-oss-test'],
          maxAgeSeconds: 10000,
        ),
      ];
      final corsConfig = CORSConfiguration(corsRules: corsRules);
      final putRequest = PutBucketCorsRequest(
        bucket: bucketName,
        corsConfiguration: corsConfig,
      );
      await expectNoAsyncError(() => client.putBucketCors(putRequest));

      // Upload an object
      final objectKey = testCase.randomObjectName();
      final putObjRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjRequest));

      // Send OPTIONS request
      final optionRequest = OptionObjectRequest(
        bucket: bucketName,
        key: objectKey,
        origin: 'http://www.example.com',
        accessControlRequestMethod: 'PUT',
        accessControlRequestHeaders: 'authorization',
      );
      final optionResult = await expectNoAsyncError(
        () => client.optionObject(optionRequest),
      );
      expect(optionResult.commonProp.statusCode, 200);
      expect(optionResult.accessControlAllowOrigin, isNotNull);
      expect(optionResult.accessControlAllowMethods, isNotNull);
    });

    test('testOptionObjectFail', () async {
      // No CORS configured, OPTIONS should fail
      final objectKey = testCase.randomObjectName();
      final putObjRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjRequest));

      final optionRequest = OptionObjectRequest(
        bucket: bucketName,
        key: objectKey,
        origin: 'http://www.example.com',
        accessControlRequestMethod: 'PUT',
      );
      await expectAsyncError(
        () => client.optionObject(optionRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(403));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
