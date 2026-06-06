import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketLoggingTests', () {
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

    test('testPutBucketLogging', () async {
      final targetBucket = testCase.randomBucketName();
      await testCase.createBucket(client, targetBucket);

      try {
        final request = PutBucketLoggingRequest(
          bucket: bucketName,
          bucketLoggingStatus: BucketLoggingStatus(
            loggingEnabled: LoggingEnabled(
              targetBucket: targetBucket,
              targetPrefix: 'targetPrefix',
            ),
          ),
        );
        final result = await expectNoAsyncError(
          () => client.putBucketLogging(request),
        );
        expect(result.commonProp.statusCode, 200);
      } finally {
        await testCase.cleanBucket(client, targetBucket);
      }
    });

    test('testGetBucketLogging', () async {
      final targetBucket = testCase.randomBucketName();
      await testCase.createBucket(client, targetBucket);

      try {
        // Put logging
        final putRequest = PutBucketLoggingRequest(
          bucket: bucketName,
          bucketLoggingStatus: BucketLoggingStatus(
            loggingEnabled: LoggingEnabled(
              targetBucket: targetBucket,
              targetPrefix: 'targetPrefix',
            ),
          ),
        );
        await expectNoAsyncError(() => client.putBucketLogging(putRequest));

        // Get logging
        final getRequest = GetBucketLoggingRequest(bucket: bucketName);
        final getResult = await expectNoAsyncError(
          () => client.getBucketLogging(getRequest),
        );
        expect(getResult.commonProp.statusCode, 200);
        expect(
          getResult.bucketLoggingStatus?.loggingEnabled?.targetBucket,
          targetBucket,
        );
        expect(
          getResult.bucketLoggingStatus?.loggingEnabled?.targetPrefix,
          'targetPrefix',
        );
      } finally {
        await testCase.cleanBucket(client, targetBucket);
      }
    });

    test('testDeleteBucketLogging', () async {
      final targetBucket = testCase.randomBucketName();
      await testCase.createBucket(client, targetBucket);

      try {
        // Put logging
        final putRequest = PutBucketLoggingRequest(
          bucket: bucketName,
          bucketLoggingStatus: BucketLoggingStatus(
            loggingEnabled: LoggingEnabled(
              targetBucket: targetBucket,
              targetPrefix: 'targetPrefix',
            ),
          ),
        );
        await expectNoAsyncError(() => client.putBucketLogging(putRequest));

        // Verify logging is set
        var getResult = await expectNoAsyncError(
          () => client.getBucketLogging(
            GetBucketLoggingRequest(bucket: bucketName),
          ),
        );
        expect(
          getResult.bucketLoggingStatus?.loggingEnabled?.targetBucket,
          targetBucket,
        );

        // Delete logging
        final deleteRequest = DeleteBucketLoggingRequest(bucket: bucketName);
        final deleteResult = await expectNoAsyncError(
          () => client.deleteBucketLogging(deleteRequest),
        );
        expect(deleteResult.commonProp.statusCode, 204);

        // Verify logging is deleted
        getResult = await expectNoAsyncError(
          () => client.getBucketLogging(
            GetBucketLoggingRequest(bucket: bucketName),
          ),
        );
        expect(
          getResult.bucketLoggingStatus?.loggingEnabled?.targetBucket,
          isNull,
        );
      } finally {
        await testCase.cleanBucket(client, targetBucket);
      }
    });

    test('testPutBucketLoggingFail', () async {
      // Missing bucketLoggingStatus
      final request = PutBucketLoggingRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.putBucketLogging(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('request.bucketLoggingStatus'));
        },
      );

      // Invalid target bucket
      final invalidRequest = PutBucketLoggingRequest(
        bucket: bucketName,
        bucketLoggingStatus: BucketLoggingStatus(
          loggingEnabled: LoggingEnabled(
            targetBucket: testCase.randomBucketName(),
          ),
        ),
      );
      await expectAsyncError(
        () => client.putBucketLogging(invalidRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('InvalidTargetBucketForLogging'));
        },
      );
    });

    test('testGetBucketLoggingFail', () async {
      // Non-existent bucket
      final request = GetBucketLoggingRequest(
        bucket: testCase.randomBucketName(),
      );
      await expectAsyncError(
        () => client.getBucketLogging(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testDeleteBucketLoggingFail', () async {
      // Non-existent bucket
      final request = DeleteBucketLoggingRequest(
        bucket: testCase.randomBucketName(),
      );
      await expectAsyncError(
        () => client.deleteBucketLogging(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testPutUserDefinedLogFieldsConfig', () async {
      final request = PutUserDefinedLogFieldsConfigRequest(
        bucket: bucketName,
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(
          headerSet: HeaderSet(headers: ['header1', 'header2', 'header3']),
          paramSet: ParamSet(parameters: ['param1', 'param2']),
        ),
      );
      final result = await expectNoAsyncError(
        () => client.putUserDefinedLogFieldsConfig(request),
      );
      expect(result.commonProp.statusCode, 200);
    });

    test('testGetUserDefinedLogFieldsConfig', () async {
      // Put config first
      final putRequest = PutUserDefinedLogFieldsConfigRequest(
        bucket: bucketName,
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(
          headerSet: HeaderSet(headers: ['header1', 'header2', 'header3']),
          paramSet: ParamSet(parameters: ['param1', 'param2']),
        ),
      );
      await expectNoAsyncError(
        () => client.putUserDefinedLogFieldsConfig(putRequest),
      );

      // Get config
      final getRequest = GetUserDefinedLogFieldsConfigRequest(
        bucket: bucketName,
      );
      final getResult = await expectNoAsyncError(
        () => client.getUserDefinedLogFieldsConfig(getRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      expect(getResult.userDefinedLogFieldsConfiguration?.headerSet?.headers, [
        'header1',
        'header2',
        'header3',
      ]);
      expect(
        getResult.userDefinedLogFieldsConfiguration?.paramSet?.parameters,
        ['param1', 'param2'],
      );
    });

    test('testPutUserDefinedLogFieldsConfigFail', () async {
      // Missing userDefinedLogFieldsConfiguration
      final request = PutUserDefinedLogFieldsConfigRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.putUserDefinedLogFieldsConfig(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(
            clientError.message,
            contains('request.userDefinedLogFieldsConfiguration'),
          );
        },
      );

      // Empty configuration
      final invalidRequest = PutUserDefinedLogFieldsConfigRequest(
        bucket: bucketName,
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(),
      );
      await expectAsyncError(
        () => client.putUserDefinedLogFieldsConfig(invalidRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('InvalidArgument'));
        },
      );
    });

    test('testGetUserDefinedLogFieldsConfigFail', () async {
      // Bucket without user defined log fields config
      final request = GetUserDefinedLogFieldsConfigRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.getUserDefinedLogFieldsConfig(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
