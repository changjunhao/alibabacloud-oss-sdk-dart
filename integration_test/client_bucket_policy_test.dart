import 'dart:convert';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketPolicyTests', () {
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

    test('testPutBucketPolicy', () async {
      final policy = {
        'Version': '1',
        'Statement': [
          {
            'Action': ['oss:PutObject', 'oss:GetObject'],
            'Effect': 'Deny',
            'Principal': ['1234567890'],
            'Resource': ['acs:oss:*:1234567890:*/*'],
          },
        ],
      };
      final policyJson = jsonEncode(policy);

      final request = PutBucketPolicyRequest(
        bucket: bucketName,
        body: policyJson,
      );
      final result = await expectNoAsyncError(
        () => client.putBucketPolicy(request),
      );
      expect(result.commonProp.statusCode, 200);
    });

    test('testGetBucketPolicy', () async {
      final policy = {
        'Version': '1',
        'Statement': [
          {
            'Action': ['oss:PutObject', 'oss:GetObject'],
            'Effect': 'Deny',
            'Principal': ['1234567890'],
            'Resource': ['acs:oss:*:1234567890:*/*'],
          },
        ],
      };
      final policyJson = jsonEncode(policy);

      // Put policy first
      final putRequest = PutBucketPolicyRequest(
        bucket: bucketName,
        body: policyJson,
      );
      await expectNoAsyncError(() => client.putBucketPolicy(putRequest));

      // Get policy
      final getRequest = GetBucketPolicyRequest(bucket: bucketName);
      final getResult = await expectNoAsyncError(
        () => client.getBucketPolicy(getRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      expect(getResult.body, isNotNull);

      // Verify policy content
      final getPolicy = jsonDecode(getResult.body!) as Map<String, dynamic>;
      expect(getPolicy['Version'], '1');
      final statements = getPolicy['Statement'] as List;
      expect(statements.length, 1);
      final statement = statements.first as Map<String, dynamic>;
      expect(statement['Effect'], 'Deny');
    });

    test('testDeleteBucketPolicy', () async {
      final policy = {
        'Version': '1',
        'Statement': [
          {
            'Action': ['oss:PutObject', 'oss:GetObject'],
            'Effect': 'Deny',
            'Principal': ['1234567890'],
            'Resource': ['acs:oss:*:1234567890:*/*'],
          },
        ],
      };
      final policyJson = jsonEncode(policy);

      // Put policy
      final putRequest = PutBucketPolicyRequest(
        bucket: bucketName,
        body: policyJson,
      );
      await expectNoAsyncError(() => client.putBucketPolicy(putRequest));

      // Verify policy exists
      final getResult = await expectNoAsyncError(
        () =>
            client.getBucketPolicy(GetBucketPolicyRequest(bucket: bucketName)),
      );
      expect(getResult.body, isNotNull);

      // Delete policy
      final deleteRequest = DeleteBucketPolicyRequest(bucket: bucketName);
      final deleteResult = await expectNoAsyncError(
        () => client.deleteBucketPolicy(deleteRequest),
      );
      expect(deleteResult.commonProp.statusCode, 204);

      // Verify policy is deleted
      await expectAsyncError(
        () =>
            client.getBucketPolicy(GetBucketPolicyRequest(bucket: bucketName)),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testGetBucketPolicyStatus', () async {
      final policy = {
        'Version': '1',
        'Statement': [
          {
            'Action': ['oss:PutObject', 'oss:GetObject'],
            'Effect': 'Deny',
            'Principal': ['1234567890'],
            'Resource': ['acs:oss:*:1234567890:*/*'],
          },
        ],
      };
      final policyJson = jsonEncode(policy);

      // Put a non-public policy (test account does not allow public policies)
      final putRequest = PutBucketPolicyRequest(
        bucket: bucketName,
        body: policyJson,
      );
      await expectNoAsyncError(() => client.putBucketPolicy(putRequest));

      // Get policy status
      final statusRequest = GetBucketPolicyStatusRequest(bucket: bucketName);
      final statusResult = await expectNoAsyncError(
        () => client.getBucketPolicyStatus(statusRequest),
      );
      expect(statusResult.commonProp.statusCode, 200);
      expect(statusResult.policyStatus?.isPublic, false);
    });

    test('testPutBucketPolicyFail', () async {
      // Missing body
      final request = PutBucketPolicyRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.putBucketPolicy(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('request.body'));
        },
      );

      // Invalid policy document (empty string)
      final invalidRequest = PutBucketPolicyRequest(
        bucket: bucketName,
        body: '',
      );
      await expectAsyncError(
        () => client.putBucketPolicy(invalidRequest),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('InvalidPolicyDocument'));
        },
      );
    });

    test('testGetBucketPolicyFail', () async {
      // Bucket without policy
      final request = GetBucketPolicyRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.getBucketPolicy(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testDeleteBucketPolicyFail', () async {
      // Non-existent bucket
      final bucket = testCase.randomBucketName();
      final request = DeleteBucketPolicyRequest(bucket: bucket);
      await expectAsyncError(
        () => client.deleteBucketPolicy(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
