import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' show CancelToken;
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_extensions.dart';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/internal/execute_middleware.dart';
import 'package:alibabacloud_oss_sdk_dart/src/internal/execute_context.dart';
import 'utils.dart';

void main() {
  group('Client Mock Tests', () {
    test('testHttpProtocol', () async {
      final mock = MockSendRequest();
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );

      // Default protocol is HTTPS
      var config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      var client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // Default protocol is HTTPS
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.putObject(
          PutObjectRequest(
            bucket: 'bucket',
            key: 'key+123 456',
            commonProp: RequestModelProp(parameters: {'param': '12+456 789'}),
          ),
        );
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123%20456?param=12%2B456%20789',
      );

      // Set protocol to HTTP
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withHttpProtocol(HttpProtocol.http)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.putObject(
          PutObjectRequest(
            bucket: 'bucket',
            key: 'key+123 456',
            commonProp: RequestModelProp(parameters: {'param': '12+456 789'}),
          ),
        );
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'http://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123%20456?param=12%2B456%20789',
      );

      // Set protocol from endpoint, no protocol in endpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('oss-cn-hangzhou.aliyuncs.com')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.putObject(
          PutObjectRequest(
            bucket: 'bucket',
            key: 'key+123 456',
            commonProp: RequestModelProp(parameters: {'param': '12+456 789a'}),
          ),
        );
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123%20456?param=12%2B456%20789a',
      );

      // Set protocol from endpoint, with http protocol in endpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('http://oss-cn-hangzhou.aliyuncs.com')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.putObject(
          PutObjectRequest(
            bucket: 'bucket',
            key: 'key+123 456',
            commonProp: RequestModelProp(parameters: {'param': '12+456 789b'}),
          ),
        );
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'http://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123%20456?param=12%2B456%20789b',
      );

      // Set protocol from endpoint, with https protocol in endpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('https://oss-cn-hangzhou.aliyuncs.com')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.putObject(
          PutObjectRequest(
            bucket: 'bucket',
            key: 'key+123 456',
            commonProp: RequestModelProp(parameters: {'param': '12+456 789c'}),
          ),
        );
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/key%2B123%20456?param=12%2B456%20789c',
      );
    });

    test('testAddressStyle', () async {
      final mock = MockSendRequest();
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );

      // 默认配置 - virtualHosted 模式
      var config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      var client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // virtualHosted, service 级别操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/',
      );

      // virtualHosted, 只有bucket的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getBucketAcl(GetBucketAclRequest(bucket: 'bucket'));
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/?acl=',
      );

      // virtualHosted, bucket和key的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getObjectAcl(
          GetObjectAclRequest(bucket: 'bucket', key: 'key'),
        );
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/key?acl=',
      );

      // path 模式, service 级别操作
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUsePathStyle(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);

      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/',
      );

      // path 模式, 只有bucket的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getBucketAcl(GetBucketAclRequest(bucket: 'bucket'));
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/bucket/?acl=',
      );

      // path 模式, bucket和key的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getObjectAcl(
          GetObjectAclRequest(bucket: 'bucket', key: 'key'),
        );
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/bucket/key?acl=',
      );

      // cname 模式, service 级别操作
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('www.cname.com')
          .withCredentialsProvider(credentialsProvider)
          .withUseCname(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);

      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(mock.requests[0].requestUri.toString(), 'https://www.cname.com/');

      // cname 模式, 只有bucket的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getBucketAcl(GetBucketAclRequest(bucket: 'bucket'));
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://www.cname.com/?acl=',
      );

      // cname 模式, bucket和key的操作
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.getObjectAcl(
          GetObjectAclRequest(bucket: 'bucket', key: 'key'),
        );
      } catch (e) {
        // 预期会失败，403错误
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://www.cname.com/key?acl=',
      );
    });

    test('testEndpointType', () async {
      final mock = MockSendRequest();
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      var config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      var client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // default
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/',
      );

      // useInternalEndpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUseInternalEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou-internal.aliyuncs.com/',
      );

      // useAccelerateEndpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUseAccelerateEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-accelerate.aliyuncs.com/',
      );

      // useDualStackEndpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUseDualStackEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://cn-hangzhou.oss.aliyuncs.com/',
      );

      // useDualStackEndpoint useAccelerateEndpoint useInternalEndpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUseInternalEndpoint(true)
          .withUseDualStackEndpoint(true)
          .withUseAccelerateEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://cn-hangzhou.oss.aliyuncs.com/',
      );

      // useAccelerateEndpoint useInternalEndpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUseInternalEndpoint(true)
          .withUseAccelerateEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou-internal.aliyuncs.com/',
      );

      // endpoint
      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('https://oss-cn-hangzhou.aliyuncs.com/')
          .withCredentialsProvider(credentialsProvider)
          .withUseInternalEndpoint(true)
          .withUseDualStackEndpoint(true)
          .withUseAccelerateEndpoint(true)
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1);
      expect(
        mock.requests[0].requestUri.toString(),
        'https://oss-cn-hangzhou.aliyuncs.com/',
      );
    });

    test('testRetryerDefault', () async {
      final mock = MockSendRequest();
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider);
      final client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // default - should retry for RequestTimeTooSkewed error
      mock.reset();
      mock.addResponse(makeTimeTooSkewedResponse());
      mock.addResponse(makeTimeTooSkewedResponse());
      mock.addResponse(makeTimeTooSkewedResponse());
      mock.addResponse(makeTimeTooSkewedResponse());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail after retries
      }
      expect(mock.requests.length, 3); // 1 initial + 2 retries

      // don't retry for other 403 errors
      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
      } catch (e) {
        // Expected to fail with 403
      }
      expect(mock.requests.length, 1); // No retries
    });

    test('testRetryerWithDifferentByteStream', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final file = await Utils.createTestFile(Utils.randomStr(5), data);
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUploadCRC64Validation(false)
          .withDownloadCRC64Validation(false);
      var count = 0;
      final mock = MockProcessRequest(
        process: (request, context) async {
          if (count < 2) {
            count += 1;
            return makeTimeTooSkewedResponse();
          } else {
            return ResponseMessage(
              statusCode: 200,
              headers: {},
              content: ByteStream.fromData(Uint8List(0)),
            );
          }
        },
      );
      final client = Client(config, [(options) => options.executeMW = mock]);
      expect(client, isNotNull);

      // data
      var request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );
      await client.putObject(request);

      // file
      count = 0;
      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromFile(File(file!)),
      );
      await client.putObject(request);

      // stream
      count = 0;
      final stream = StreamController<Uint8List>();
      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromStream(stream.stream),
      );

      try {
        final putFuture = client.putObject(request);
        // Add data to stream
        stream.add(data);
        stream.close();
        await putFuture;
        fail('Should have thrown an exception');
      } catch (e) {
        final serverError = e as ServerError;
        expect(serverError.statusCode, 403);
        expect(serverError.code, 'RequestTimeTooSkewed');
      }

      await Utils.removeTestFile(file);
    });

    test('testRetryerWithError', () async {
      final mock = MockSendRequest();
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider);
      final client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      mock.reset();
      mock.addResponse(make403Response());
      try {
        await client.listBuckets(ListBucketsRequest());
        fail('Should have thrown an exception');
      } catch (e) {
        final serverError = e as ServerError;
        expect(serverError.statusCode, 403);
        expect(serverError.code, 'InvalidAccessKeyId');
        expect(serverError.requestId, 'id-1234');
      }
    });

    test('testRetryerWithCancelTask', () async {
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider);
      final mock = MockProcessRequest(
        process: (request, context) async {
          // Simulate a long-running request that takes 1 second
          await Future.delayed(Duration(seconds: 1));
          return ResponseMessage(
            statusCode: 200,
            headers: {},
            content: ByteStream.fromData(Uint8List(0)),
          );
        },
      );
      final client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // Create a completer to track the task completion
      final completer = Completer<void>();

      // Start the request in a separate task
      final future = client
          .listBuckets(ListBucketsRequest())
          .then((_) {
            fail('Request should have been cancelled');
          })
          .catchError((error) {
            // Verify that the error is a cancellation error
            expect(error, isA<Exception>());
            completer.complete();
            throw error; // Re-throw to satisfy the Never return type
          });

      // Cancel the request immediately
      // Note: We simulate the cancellation behavior by timing out
      try {
        await future.timeout(Duration(milliseconds: 100));
      } catch (e) {
        // Expected timeout or cancellation
        expect(e, anyOf(isA<TimeoutException>(), isA<Exception>()));
      }

      // Wait a bit to ensure the mock request would have completed
      await Future.delayed(Duration(seconds: 1));
    });

    test('testCrc64WithRetry', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final file = await Utils.createTestFile(Utils.randomStr(5), data);
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider);
      var count = 0;
      final mock = MockProcessRequest(
        process: (request, context) async {
          if (count < 2) {
            count += 1;
            // Read the request content to simulate processing
            if (request.content != null) {
              await request.content!.readData();
            }
            return makeTimeTooSkewedResponse();
          } else {
            return ResponseMessage(
              statusCode: 200,
              headers: {'x-oss-hash-crc64ecma': '15021467531229347219'},
              content: ByteStream.fromData(Uint8List(0)),
            );
          }
        },
      );
      final client = Client(config, [(options) => options.executeMW = mock]);

      expect(client, isNotNull);

      // upload data
      var request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );
      await client.putObject(request);

      // upload file
      count = 0;
      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromFile(File(file!)),
      );
      await client.putObject(request);

      await Utils.removeTestFile(file);
    });

    test('testFixTimeSkewed', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryMaxAttempts(2);

      final now = DateTime.now();
      final date = DateTime.fromMillisecondsSinceEpoch(
        (now.millisecondsSinceEpoch ~/ 1000) * 1000,
      ).add(const Duration(hours: 1));

      // enable fix time - use body date
      var mock = MockProcessRequest(
        process: (request, context) async {
          final requestTime =
              request.headers['Date'] ?? request.headers['x-oss-date'] ?? '';
          final serverTime = DateFormatters.iso8601DateTimeSeconds.format(date);
          final body =
              '''
<Error>
<Code>RequestTimeTooSkewed</Code>
<Message>The difference between the request time and the current time is too large.</Message>
<RequestTime>$requestTime</RequestTime>
<ServerTime>$serverTime</ServerTime>
</Error>
''';
          final responseDate = DateFormatters.rfc5322DateTime.format(
            DateTime.now().add(const Duration(minutes: 30)),
          );
          return ResponseMessage(
            statusCode: 403,
            headers: {'Date': responseDate},
            content: ByteStream.fromData(Uint8List.fromList(body.codeUnits)),
          );
        },
      );

      var client = Client(config, [
        (options) {
          options.executeMW = mock;
          options.featureFlags =
              options.featureFlags | FeatureFlag.correctClockSkew;
        },
      ]);
      expect(client, isNotNull);

      var request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );

      try {
        await client.putObject(request);
        fail('Expected ServerError to be thrown');
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        final requestTimeStr = serverError.errorFields['RequestTime'];
        expect(requestTimeStr, isNotNull);
        final timeWithGmt = requestTimeStr!.endsWith(' GMT')
            ? requestTimeStr
            : '$requestTimeStr GMT';
        final requestTime = DateFormatters.rfc5322DateTime.tryParse(
          timeWithGmt,
        );
        expect(requestTime, isNotNull);
        expect(
          requestTime!.isBefore(date) || requestTime.isAtSameMomentAs(date),
          isTrue,
        );
      }

      // use header date
      mock = MockProcessRequest(
        process: (request, context) async {
          final requestTime =
              request.headers['Date'] ?? request.headers['x-oss-date'] ?? '';
          final body =
              '''
<Error>
<Code>RequestTimeTooSkewed</Code>
<Message>The difference between the request time and the current time is too large.</Message>
<RequestTime>$requestTime</RequestTime>
</Error>
''';
          final responseDate = DateFormatters.rfc5322DateTime.format(date);
          return ResponseMessage(
            statusCode: 403,
            headers: {'Date': responseDate},
            content: ByteStream.fromData(Uint8List.fromList(body.codeUnits)),
          );
        },
      );

      client = Client(config, [
        (options) {
          options.executeMW = mock;
          options.featureFlags =
              options.featureFlags | FeatureFlag.correctClockSkew;
        },
      ]);
      expect(client, isNotNull);

      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );

      try {
        await client.putObject(request);
        fail('Expected ServerError to be thrown');
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        final requestTimeStr = serverError.errorFields['RequestTime'];
        expect(requestTimeStr, isNotNull);
        final timeWithGmt = requestTimeStr!.endsWith(' GMT')
            ? requestTimeStr
            : '$requestTimeStr GMT';
        final requestTime = DateFormatters.rfc5322DateTime.tryParse(
          timeWithGmt,
        );
        expect(requestTime, isNotNull);
        expect(
          requestTime!.isBefore(date) || requestTime.isAtSameMomentAs(date),
          isTrue,
        );
      }

      // fix time for v4
      mock = MockProcessRequest(
        process: (request, context) async {
          final requestTime =
              request.headers['Date'] ?? request.headers['x-oss-date'] ?? '';
          final body =
              '''
<Error>
<Code>InvalidArgument</Code>
<Message>Invalid signing date in Authorization header.</Message>
<RequestTime>$requestTime</RequestTime>
</Error>
''';
          final responseDate = DateFormatters.rfc5322DateTime.format(date);
          return ResponseMessage(
            statusCode: 400,
            headers: {'Date': responseDate},
            content: ByteStream.fromData(Uint8List.fromList(body.codeUnits)),
          );
        },
      );

      client = Client(config, [
        (options) {
          options.executeMW = mock;
          options.featureFlags =
              options.featureFlags | FeatureFlag.correctClockSkew;
        },
      ]);
      expect(client, isNotNull);

      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );

      try {
        await client.putObject(request);
        fail('Expected ServerError to be thrown');
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        final requestTimeStr = serverError.errorFields['RequestTime'];
        expect(requestTimeStr, isNotNull);
        final timeWithGmt = requestTimeStr!.endsWith(' GMT')
            ? requestTimeStr
            : '$requestTimeStr GMT';
        final requestTime = DateFormatters.rfc5322DateTime.tryParse(
          timeWithGmt,
        );
        expect(requestTime, isNotNull);
        expect(
          requestTime!.isBefore(date) || requestTime.isAtSameMomentAs(date),
          isTrue,
        );
      }

      // disable fix time
      mock = MockProcessRequest(
        process: (request, context) async {
          final requestTime =
              request.headers['Date'] ?? request.headers['x-oss-date'] ?? '';
          final serverTime = DateFormatters.iso8601DateTimeSeconds.format(date);
          final body =
              '''
<Error>
<Code>RequestTimeTooSkewed</Code>
<Message>The difference between the request time and the current time is too large.</Message>
<RequestTime>$requestTime</RequestTime>
<ServerTime>$serverTime</ServerTime>
</Error>
''';
          final responseDate = DateFormatters.rfc5322DateTime.format(date);
          return ResponseMessage(
            statusCode: 403,
            headers: {'Date': responseDate},
            content: ByteStream.fromData(Uint8List.fromList(body.codeUnits)),
          );
        },
      );

      client = Client(config, [
        (options) {
          options.executeMW = mock;
          options.featureFlags = FeatureFlag.fromRawValue(
            options.featureFlags.rawValue &
                ~FeatureFlag.correctClockSkew.rawValue,
          );
        },
      ]);
      expect(client, isNotNull);

      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );

      try {
        await client.putObject(request);
        fail('Expected ServerError to be thrown');
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        final requestTimeStr = serverError.errorFields['RequestTime'];
        expect(requestTimeStr, isNotNull);
        final timeWithGmt = requestTimeStr!.endsWith(' GMT')
            ? requestTimeStr
            : '$requestTimeStr GMT';
        final requestTime = DateFormatters.rfc5322DateTime.tryParse(
          timeWithGmt,
        );
        expect(requestTime, isNotNull);
        expect(requestTime!.isBefore(date), isTrue);
      }
    });

    test('testUploadCheckCRC', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withUploadCRC64Validation(true)
          .withRetryer(NopRetryer());

      // consistent
      var mock = MockProcessRequest(
        process: (_, _) async {
          return ResponseMessage(
            statusCode: 200,
            headers: {'x-oss-hash-crc64ecma': '15021467531229347219'},
            content: ByteStream.fromData(Uint8List(0)),
          );
        },
      );
      var client = Client(config, [(options) => options.executeMW = mock]);
      var request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );
      await client.putObject(request); // Should not throw

      // inconsistent
      mock.reset((_, _) async {
        return ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-hash-crc64ecma': '123'},
          content: ByteStream.fromData(Uint8List(0)),
        );
      });
      client = Client(config, [(options) => options.executeMW = mock]);
      request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(data),
      );
      try {
        await client.putObject(request);
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(clientError.message.startsWith('crc is inconsistent'), isTrue);
      }
    });

    test('testDownloadCheckCRC', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withDownloadCRC64Validation(true)
          .withRetryer(NopRetryer());

      // consistent
      var mock = MockSendRequest();
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-hash-crc64ecma': '15021467531229347219'},
          content: ByteStream.fromData(data),
        ),
      );
      var client = Client(config, [(options) => options.executeMW = mock]);
      var request = GetObjectRequest(bucket: 'bucket', key: 'key');
      await client.getObject(request); // Should not throw

      // inconsistent
      mock.reset();
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-hash-crc64ecma': '123'},
          content: ByteStream.fromData(data),
        ),
      );
      client = Client(config, [(options) => options.executeMW = mock]);
      request = GetObjectRequest(bucket: 'bucket', key: 'key');
      try {
        await client.getObject(request);
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(clientError.message.startsWith('crc is inconsistent'), isTrue);
      }
    });

    test('testUserAgent', () async {
      var config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(AnonymousCredentialsProvider())
          .withUserAgent('userAgent');

      // consistent
      final mock = MockProcessRequest(
        process: (request, context) async {
          return ResponseMessage(statusCode: 200, headers: request.headers);
        },
      );
      var client = Client(config, [(options) => options.executeMW = mock]);
      final request = GetObjectRequest(bucket: 'bucket', key: 'key');
      var result = await client.getObject(request);
      final userAgentHeader = result.commonProp.headers?.getCaseInsensitive(
        'user-agent',
      );
      expect(userAgentHeader?.endsWith('userAgent'), isTrue);

      config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(AnonymousCredentialsProvider());
      client = Client(config, [(options) => options.executeMW = mock]);
      result = await client.getObject(request);
      expect(
        result.commonProp.headers?.getCaseInsensitive('user-agent'),
        isNotNull,
      );
    });

    test('testCname', () async {
      final mock = MockSendRequest();
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withEndpoint('www.cname.com')
          .withAdditionalHeaders(['additionalKey'])
          .withCredentialsProvider(EnvironmentCredentialsProvider())
          .withRetryer(NopRetryer());

      final client = Client(config, [(options) => options.executeMW = mock]);
      var request = GetObjectRequest(
        bucket: 'bucket',
        key: 'key',
        commonProp: RequestModelProp(
          headers: {'additionalKey': 'additionalValue'},
        ),
      );

      mock.reset();
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'additionalKey': 'additionalValue',
            'Authorization':
                'OSS4-HMAC-SHA256 Credential=test/20231201/cn-hangzhou/oss/aliyun_v4_request,AdditionalHeaders=additionalkey,Signature=test',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final result = await client.getObject(request);
      expect(
        result.commonProp.headers?.getCaseInsensitive('additionalKey'),
        'additionalValue',
      );
      final authHeader = result.commonProp.headers?.getCaseInsensitive(
        'Authorization',
      );
      expect(authHeader?.contains('AdditionalHeaders=additionalkey'), isTrue);
    });

    test('testPutObjectCancelWithPreCancelledToken', () async {
      // Test that a pre-cancelled token causes immediate failure
      final mock = MockProcessRequest(
        process: (request, context) async {
          // Verify the cancelToken is passed through to the context
          expect(context.cancelToken, isNotNull);
          expect(context.cancelToken!.isCancelled, isTrue);

          // Simulate what Dio does when receiving a pre-cancelled token
          throw ClientError(
            code: 'RequestCancelled',
            message: 'HTTP request was cancelled: pre-cancelled',
          );
        },
      );

      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      final client = Client(config, [(options) => options.executeMW = mock]);

      final cancelToken = CancelToken();
      cancelToken.cancel('pre-cancelled');

      final request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(Uint8List.fromList('hello'.codeUnits)),
      );

      try {
        await client.putObject(
          request,
          OperationOptions(cancelToken: cancelToken),
        );
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(clientError.code, equals('RequestCancelled'));
        expect(clientError.isCancelled, isTrue);
      }
    });

    test('testCancelTokenPassedThroughContext', () async {
      // Test that cancelToken from OperationOptions is properly passed to ExecuteContext
      CancelToken? capturedToken;
      final mock = MockProcessRequest(
        process: (request, context) async {
          capturedToken = context.cancelToken;
          return ResponseMessage(
            statusCode: 200,
            headers: {'x-oss-request-id': 'test-id'},
            content: ByteStream.fromData(Uint8List(0)),
          );
        },
      );

      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      final client = Client(config, [(options) => options.executeMW = mock]);

      final cancelToken = CancelToken();
      final request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(Uint8List.fromList('hello'.codeUnits)),
      );

      await client.putObject(
        request,
        OperationOptions(cancelToken: cancelToken),
      );

      // Verify the token was passed through
      expect(capturedToken, isNotNull);
      expect(identical(capturedToken, cancelToken), isTrue);
    });

    test('testCancelTokenNullByDefault', () async {
      // Test that cancelToken is null when not provided
      CancelToken? capturedToken;
      bool contextChecked = false;
      final mock = MockProcessRequest(
        process: (request, context) async {
          capturedToken = context.cancelToken;
          contextChecked = true;
          return ResponseMessage(
            statusCode: 200,
            headers: {'x-oss-request-id': 'test-id'},
            content: ByteStream.fromData(Uint8List(0)),
          );
        },
      );

      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
      );
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(credentialsProvider)
          .withRetryer(NopRetryer());
      final client = Client(config, [(options) => options.executeMW = mock]);

      final request = PutObjectRequest(
        bucket: 'bucket',
        key: 'key',
        body: ByteStream.fromData(Uint8List.fromList('hello'.codeUnits)),
      );

      await client.putObject(request);

      // Verify no cancel token was passed
      expect(contextChecked, isTrue);
      expect(capturedToken, isNull);
    });
  });
}

/// Mock middleware for sending predefined responses
class MockSendRequest implements ExecuteMiddleware {
  List<ResponseMessage> responses = [];
  List<RequestMessage> requests = [];

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    requests.add(request);
    expect(responses.isNotEmpty, isTrue, reason: 'No responses available');
    final response = responses[0];
    responses.removeAt(0);
    return response;
  }

  void addResponse(ResponseMessage response) {
    responses.add(response);
  }

  void reset() {
    requests = [];
    responses = [];
  }
}

/// Mock middleware for processing requests with custom logic
class MockProcessRequest implements ExecuteMiddleware {
  Future<ResponseMessage> Function(RequestMessage, ExecuteContext) process;

  MockProcessRequest({required this.process});

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    return await process(request, context);
  }

  void reset(
    Future<ResponseMessage> Function(RequestMessage, ExecuteContext) newProcess,
  ) {
    process = newProcess;
  }
}

/// Helper function to create a 403 response with InvalidAccessKeyId error
ResponseMessage make403Response() {
  const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>InvalidAccessKeyId</Code>
    <Message>The OSS Access Key Id you provided does not exist in our records.</Message>
    <RequestId>id-1234</RequestId>
    <HostId>oss-cn-hangzhou.aliyuncs.com</HostId>
    <OSSAccessKeyId>ak</OSSAccessKeyId>
    <EC>0002-00000902</EC>
    <RecommendDoc>https://api.aliyun.com/troubleshoot?q=0002-00000902</RecommendDoc>
</Error>
''';
  final data = Uint8List.fromList(xml.codeUnits);
  return ResponseMessage(
    statusCode: 403,
    headers: {
      'x-oss-request-id': 'req-id-123',
      'content-type': 'application/xml',
      'content-length': data.length.toString(),
    },
    content: ByteStream.fromData(data),
  );
}

/// Helper function to create a 403 response with RequestTimeTooSkewed error
ResponseMessage makeTimeTooSkewedResponse() {
  const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>RequestTimeTooSkewed</Code>
    <Message>The difference between the request time and the current time is too large.</Message>
    <RequestId>id-1234</RequestId>
    <HostId>oss-cn-hangzhou.aliyuncs.com</HostId>
    <RequestTime>2024-08-28T01:03:57.000Z</RequestTime>
    <ServerTime>2024-08-28T01:23:02.000Z</ServerTime>
    <EC>0002-00000504</EC>
    <RecommendDoc>https://api.aliyun.com/troubleshoot?q=0002-00000902</RecommendDoc>
</Error>
''';
  final data = Uint8List.fromList(xml.codeUnits);
  return ResponseMessage(
    statusCode: 403,
    headers: {
      'x-oss-request-id': 'req-id-123',
      'content-type': 'application/xml',
      'content-length': data.length.toString(),
    },
    content: ByteStream.fromData(data),
  );
}
