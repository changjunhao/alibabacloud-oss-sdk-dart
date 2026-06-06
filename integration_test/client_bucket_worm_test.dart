import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketWormTests', () {
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
      // Abort worm if it is in InProgress state before cleaning bucket
      try {
        await client.abortBucketWorm(
          AbortBucketWormRequest(bucket: bucketName),
        );
      } catch (_) {}
      await testCase.cleanBucket(client, bucketName);
    });

    test('testInitiateBucketWorm', () async {
      final request = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 1,
        ),
      );
      final result = await expectNoAsyncError(
        () => client.initiateBucketWorm(request),
      );
      expect(result.commonProp.statusCode, 200);
      expect(result.wormId, isNotNull);
    });

    test('testAbortBucketWorm', () async {
      // Initiate worm first
      final initiateRequest = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 1,
        ),
      );
      await expectNoAsyncError(
        () => client.initiateBucketWorm(initiateRequest),
      );

      // Verify worm exists
      final getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 1);

      // Abort worm
      final abortRequest = AbortBucketWormRequest(bucket: bucketName);
      final abortResult = await expectNoAsyncError(
        () => client.abortBucketWorm(abortRequest),
      );
      expect(abortResult.commonProp.statusCode, 204);

      // Verify worm is aborted
      await expectAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchWORMConfiguration'));
        },
      );
    });

    test('testCompleteBucketWorm', () async {
      // Initiate worm
      final initiateRequest = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 1,
        ),
      );
      final initiateResult = await expectNoAsyncError(
        () => client.initiateBucketWorm(initiateRequest),
      );

      // Get worm to verify state
      var getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 1);
      expect(getResult.wormConfiguration?.state, WormState.inProgress);

      // Complete worm
      final completeRequest = CompleteBucketWormRequest(
        bucket: bucketName,
        wormId: initiateResult.wormId,
      );
      final completeResult = await expectNoAsyncError(
        () => client.completeBucketWorm(completeRequest),
      );
      expect(completeResult.commonProp.statusCode, 200);

      // Verify worm state is Locked
      getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 1);
      expect(getResult.wormConfiguration?.state, WormState.locked);
    });

    test('testExtendBucketWorm', () async {
      // Initiate worm
      final initiateRequest = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 1,
        ),
      );
      final initiateResult = await expectNoAsyncError(
        () => client.initiateBucketWorm(initiateRequest),
      );

      // Complete worm
      final completeRequest = CompleteBucketWormRequest(
        bucket: bucketName,
        wormId: initiateResult.wormId,
      );
      await expectNoAsyncError(
        () => client.completeBucketWorm(completeRequest),
      );

      // Get worm to get wormId
      var getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 1);
      expect(getResult.wormConfiguration?.state, WormState.locked);

      // Extend worm
      final extendRequest = ExtendBucketWormRequest(
        bucket: bucketName,
        wormId: getResult.wormConfiguration?.wormId,
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 2,
        ),
      );
      final extendResult = await expectNoAsyncError(
        () => client.extendBucketWorm(extendRequest),
      );
      expect(extendResult.commonProp.statusCode, 200);

      // Verify extended retention period
      getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 2);
    });

    test('testGetBucketWorm', () async {
      // Initially no worm configured
      await expectAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchWORMConfiguration'));
        },
      );

      // Initiate worm
      final initiateRequest = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 1,
        ),
      );
      await expectNoAsyncError(
        () => client.initiateBucketWorm(initiateRequest),
      );

      // Get worm and verify
      final getResult = await expectNoAsyncError(
        () => client.getBucketWorm(GetBucketWormRequest(bucket: bucketName)),
      );
      expect(getResult.commonProp.statusCode, 200);
      expect(getResult.wormConfiguration?.retentionPeriodInDays, 1);
      expect(getResult.wormConfiguration?.wormId, isNotNull);
      expect(getResult.wormConfiguration?.state, isNotNull);
      expect(getResult.wormConfiguration?.creationDate, isNotNull);
    });

    test('testInitiateBucketWormFail', () async {
      // Missing initiateWormConfiguration
      final request = InitiateBucketWormRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.initiateBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(
            clientError.message,
            contains('request.initiateWormConfiguration'),
          );
        },
      );

      // Empty configuration (missing retentionPeriodInDays)
      final invalidRequest = InitiateBucketWormRequest(
        bucket: bucketName,
        initiateWormConfiguration: InitiateWormConfiguration(),
      );
      await expectAsyncError(
        () => client.initiateBucketWorm(invalidRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('MalformedXML'));
        },
      );
    });

    test('testAbortBucketWormFail', () async {
      // Non-existent bucket
      final bucket = testCase.randomBucketName();
      final request = AbortBucketWormRequest(bucket: bucket);
      await expectAsyncError(
        () => client.abortBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testGetBucketWormFail', () async {
      // Non-existent bucket
      final bucket = testCase.randomBucketName();
      final request = GetBucketWormRequest(bucket: bucket);
      await expectAsyncError(
        () => client.getBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testExtendBucketWormFail', () async {
      // Missing wormId
      var request = ExtendBucketWormRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.extendBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('request.wormId'));
        },
      );

      // Missing extendWormConfiguration
      request = ExtendBucketWormRequest(bucket: bucketName, wormId: 'wormId');
      await expectAsyncError(
        () => client.extendBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(
            clientError.message,
            contains('request.extendWormConfiguration'),
          );
        },
      );

      // Non-existent bucket with complete params
      final bucket = testCase.randomBucketName();
      request = ExtendBucketWormRequest(
        bucket: bucket,
        wormId: 'wormId',
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 2,
        ),
      );
      await expectAsyncError(
        () => client.extendBucketWorm(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
