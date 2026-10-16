import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart'
    as oss;
import '../client_mock_test.dart' show MockProcessRequest;
import 'package:alibabacloud_oss_sdk_dart/src/internal/client_impl.dart';
import 'package:alibabacloud_oss_sdk_dart/src/configuration.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/anonymous_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/static_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/attributes.dart';
import 'package:alibabacloud_oss_sdk_dart/src/enums.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signer_v1.dart';
import 'package:alibabacloud_oss_sdk_dart/src/signer/signer_v4.dart';
import 'package:alibabacloud_oss_sdk_dart/src/retry/retryer.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('ClientImpl Tests', () {
    for (final account in ['abc', ' 137', '137\n', '１２３', '١٣٧']) {
      test(
        'Account format deferred error without credential fetch: ${account.codeUnits}',
        () async {
          var credentialCalls = 0;
          var sent = 0;
          final client = ClientImpl(
            Configuration(
              accountId: account,
              credentialsProvider: oss.ClosureCredentialsProvider(() async {
                credentialCalls++;
                return oss.Credentials(
                  accessKeyId: 'ak',
                  accessKeySecret: 'sk',
                );
              }),
            ),
            [
              (o) => o.executeMW = MockProcessRequest(
                process: (r, c) async {
                  sent++;
                  return oss.ResponseMessage(statusCode: 200, headers: {});
                },
              ),
            ],
          );
          addTearDown(client.dispose);
          final input = OperationInput(bucket: '-invalid');
          final matcher = isA<ClientError>().having(
            (e) => e.message,
            'message',
            contains('Account id'),
          );
          await expectLater(client.execute(input), throwsA(matcher));
          await expectLater(client.presignInner(input), throwsA(matcher));
          expect(credentialCalls, 0);
          expect(sent, 0);
        },
      );
    }

    test('Endpoint error takes precedence over bucket validation', () async {
      final client = ClientImpl(Configuration());
      addTearDown(client.dispose);
      await expectLater(
        client.execute(OperationInput(bucket: '-invalid')),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            'Endpoint is invalid.',
          ),
        ),
      );
    });

    for (final account in <String?>[null, '', '00137']) {
      test('Regular client allows account ${account ?? 'null'}', () async {
        final client = ClientImpl(
          Configuration(region: 'cn-hangzhou', accountId: account),
        );
        addTearDown(client.dispose);
        expect(
          (await client.presignInner(
            OperationInput(method: 'GET', bucket: 'bucket'),
          )).url,
          'https://bucket.oss-cn-hangzhou.aliyuncs.com/',
        );
      });
    }

    test('Addressing priority and plain alias fallback', () async {
      final cases = [
        (
          Configuration(region: 'cn-hangzhou', useVirtualHostedAlias: true),
          AddressStyleType.virtualHostedAlias,
        ),
        (
          Configuration(
            region: 'cn-hangzhou',
            useVirtualHostedAlias: true,
            usePathStyle: true,
          ),
          AddressStyleType.path,
        ),
        (
          Configuration(
            region: 'cn-hangzhou',
            useVirtualHostedAlias: true,
            usePathStyle: true,
            useCname: true,
          ),
          AddressStyleType.cname,
        ),
        (
          Configuration(
            endpoint: 'http://127.0.0.1:8080',
            useCname: true,
            useVirtualHostedAlias: true,
          ),
          AddressStyleType.path,
        ),
        (
          Configuration(
            endpoint: 'http://[::1]:8080',
            useVirtualHostedAlias: true,
          ),
          AddressStyleType.path,
        ),
      ];
      for (final entry in cases) {
        final client = ClientImpl(entry.$1);
        addTearDown(client.dispose);
        expect(client.options.addressStyle, entry.$2);
      }
      final client = ClientImpl(cases.first.$1);
      addTearDown(client.dispose);
      expect(
        (await client.presignInner(
          OperationInput(method: 'GET', bucket: 'bucket', key: 'key'),
        )).url,
        'https://bucket.oss-cn-hangzhou.aliyuncs.com/key',
      );
    });

    test(
      'Independent hooks override execute and presign without mutating input; copy preserves callbacks',
      () async {
        final signingBuckets = <String?>[];
        var resolverCalls = 0;
        String resolver(OperationInput input) {
          resolverCalls++;
          return '${input.bucket}-physical';
        }

        String provider(OperationInput input) =>
            'https://alias.example:8443/base/key';
        final client = ClientImpl(
          Configuration(
            region: 'cn-hangzhou',
            credentialsProvider: AnonymousCredentialsProvider(),
          ),
          [
            (o) {
              o.bucketNameResolver = resolver;
              o.endpointProvider = provider;
              o.executeMW = MockProcessRequest(
                process: (r, c) async {
                  signingBuckets.add(c.signingContext!.bucket);
                  expect(
                    r.requestUri.toString(),
                    'https://alias.example:8443/base/key?q=a%2Bb%20c',
                  );
                  return oss.ResponseMessage(statusCode: 200, headers: {});
                },
              );
            },
          ],
        );
        addTearDown(client.dispose);
        final copied = client.options.copyWith();
        expect(copied.bucketNameResolver, same(resolver));
        expect(copied.endpointProvider, same(provider));
        final input = OperationInput(
          method: 'GET',
          bucket: 'bucket',
          key: 'key',
          parameters: {'q': 'a+b c'},
          headers: {'X-Test': 'value'},
        );
        await client.execute(input);
        final signed = await client.presignInner(input);
        expect(signed.url, 'https://alias.example:8443/base/key?q=a%2Bb%20c');
        expect(signingBuckets, ['bucket-physical']);
        expect(resolverCalls, 2);
        expect(input.bucket, 'bucket');
        expect(input.key, 'key');
        expect(input.headers, {'X-Test': 'value'});
        expect(input.parameters, {'q': 'a+b c'});
        await client.presignInner(OperationInput(method: 'GET'));
        expect(resolverCalls, 2);
      },
    );

    test('testClientImplConstructor', () {
      final credentialsProvider = AnonymousCredentialsProvider();
      const endpoint = 'oss-cn-hangzhou.aliyuncs.com';
      final config = Configuration.defaultConfig()
          .withEndpoint(endpoint)
          .withCredentialsProvider(credentialsProvider);

      var client = ClientImpl(config);
      expect(client, isNotNull);
      expect(client.options.region, equals(''));

      client = ClientImpl(config, [
        (options) => options.region = 'cn-hangzhou',
      ]);
      expect(client.options.region, equals('cn-hangzhou'));

      client = ClientImpl(config, [
        (options) => options.region = 'cn-hangzhou',
        (options) => options.region = 'cn-beijing',
      ]);
      expect(client.options.region, equals('cn-beijing'));
    });

    test('testResolveEndpoint', () {
      // endpoint
      var endpoint = 'oss-cn-beijing.aliyuncs.com';
      var config = Configuration.defaultConfig().withEndpoint(endpoint);
      var client = ClientImpl(config);
      expect(client.options.endpoint, isNotNull);

      // invalid endpoint
      endpoint = '';
      config = Configuration.defaultConfig().withEndpoint(endpoint);
      client = ClientImpl(config);
      expect(client.options.endpoint, isNull);

      // region
      const region = 'cn-beijing';
      config = Configuration.defaultConfig().withRegion(region);
      client = ClientImpl(config);
      expect(client.options.endpoint?.host, equals('oss-$region.aliyuncs.com'));
      expect(client.options.endpoint?.scheme, equals('https'));

      config = Configuration.defaultConfig()
          .withRegion(region)
          .withUseInternalEndpoint(true);
      client = ClientImpl(config);
      expect(
        client.options.endpoint?.host,
        equals('oss-$region-internal.aliyuncs.com'),
      );
      expect(client.options.endpoint?.scheme, equals('https'));

      config = Configuration.defaultConfig()
          .withRegion(region)
          .withUseAccelerateEndpoint(true);
      client = ClientImpl(config);
      expect(
        client.options.endpoint?.host,
        equals('oss-accelerate.aliyuncs.com'),
      );
      expect(client.options.endpoint?.scheme, equals('https'));

      config = Configuration.defaultConfig()
          .withRegion(region)
          .withUseDualStackEndpoint(true);
      client = ClientImpl(config);
      expect(client.options.endpoint?.host, equals('$region.oss.aliyuncs.com'));
      expect(client.options.endpoint?.scheme, equals('https'));

      // ssl
      config = Configuration.defaultConfig()
          .withRegion(region)
          .withHttpProtocol(HttpProtocol.http);
      client = ClientImpl(config);
      expect(client.options.endpoint?.host, equals('oss-$region.aliyuncs.com'));
      expect(client.options.endpoint?.scheme, equals('http'));
    });

    test('testResolveRetryer', () {
      const maxRetryCount = 10;
      var config = Configuration.defaultConfig().withRetryMaxAttempts(
        maxRetryCount,
      );
      var client = ClientImpl(config);
      expect(client.options.retryer, isNotNull);
      expect(client.options.retryer.maxAttempts(), equals(maxRetryCount));

      config = Configuration.defaultConfig()
          .withRetryer(TestRetryer())
          .withRetryMaxAttempts(maxRetryCount);
      client = ClientImpl(config);
      expect(client.options.retryer.maxAttempts(), equals(1));
    });

    test('testResolveSigner', () {
      var config = Configuration.defaultConfig();
      var client = ClientImpl(config);
      expect(client.options.signer, isA<SignerV4>());

      config = Configuration.defaultConfig().withSignerVersion(
        SignerVersion.v1,
      );
      client = ClientImpl(config);
      expect(client.options.signer, isA<SignerV1>());
    });

    test('testResolveAddressStyle', () {
      // default
      var config = Configuration.defaultConfig();
      var client = ClientImpl(config);
      expect(
        client.options.addressStyle,
        equals(AddressStyleType.virtualHosted),
      );

      // cname
      config = Configuration.defaultConfig().withUseCname(true);
      client = ClientImpl(config);
      expect(client.options.addressStyle, equals(AddressStyleType.cname));

      // path
      config = Configuration.defaultConfig().withUsePathStyle(true);
      client = ClientImpl(config);
      expect(client.options.addressStyle, equals(AddressStyleType.path));

      // ip
      config = Configuration.defaultConfig().withEndpoint('192.169.0.1');
      client = ClientImpl(config);
      expect(client.options.addressStyle, equals(AddressStyleType.path));

      config = Configuration.defaultConfig().withEndpoint(
        '[fe80::200:ff:fe00:400]',
      );
      client = ClientImpl(config);
      expect(client.options.addressStyle, equals(AddressStyleType.path));
    });

    test('testResolveFeatureFlags', () {
      // default
      var config = Configuration.defaultConfig();
      var client = ClientImpl(config);
      expect(
        client.options.featureFlags.contains(FeatureFlag.correctClockSkew),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.autoDetectMimeType),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckDownload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckUpload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.enableMD5),
        isFalse,
      );

      // CRC64CheckUpload
      config = Configuration.defaultConfig().withUploadCRC64Validation(true);
      client = ClientImpl(config);
      expect(
        client.options.featureFlags.contains(FeatureFlag.correctClockSkew),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.autoDetectMimeType),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckDownload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckUpload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.enableMD5),
        isFalse,
      );

      config = Configuration.defaultConfig().withUploadCRC64Validation(false);
      client = ClientImpl(config);
      expect(
        client.options.featureFlags.contains(FeatureFlag.correctClockSkew),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.autoDetectMimeType),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckDownload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckUpload,
        ),
        isFalse,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.enableMD5),
        isFalse,
      );

      // CRC64CheckDownload
      config = Configuration.defaultConfig().withDownloadCRC64Validation(true);
      client = ClientImpl(config);
      expect(
        client.options.featureFlags.contains(FeatureFlag.correctClockSkew),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.autoDetectMimeType),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckDownload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckUpload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.enableMD5),
        isFalse,
      );

      config = Configuration.defaultConfig().withDownloadCRC64Validation(false);
      client = ClientImpl(config);
      expect(
        client.options.featureFlags.contains(FeatureFlag.correctClockSkew),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.autoDetectMimeType),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckDownload,
        ),
        isFalse,
      );
      expect(
        client.options.featureFlags.contains(
          FeatureFlag.enableCRC64CheckUpload,
        ),
        isTrue,
      );
      expect(
        client.options.featureFlags.contains(FeatureFlag.enableMD5),
        isFalse,
      );
    });

    test('testConfigUserAgent', () {
      final config = Configuration.defaultConfig();
      final client = ClientImpl(config);
      expect(client.innerOptions, isNotNull);
      expect(client.innerOptions.userAgent, isNotNull);
    });

    test('testBuildHostPath', () {
      // virtual hosted
      var input = OperationInput();
      var hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.virtualHosted,
      );
      expect(hostPath, equals('oss-cn-hangzhou.aliyuncs.com/'));

      input.bucket = 'test-bucket';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.virtualHosted,
      );
      expect(hostPath, equals('test-bucket.oss-cn-hangzhou.aliyuncs.com/'));

      input.bucket = 'test-bucket';
      input.key = 'special/test-key+123';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.virtualHosted,
      );
      expect(
        hostPath,
        equals(
          'test-bucket.oss-cn-hangzhou.aliyuncs.com/special/test-key%2B123',
        ),
      );

      // path style
      input = OperationInput();
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.path,
      );
      expect(hostPath, equals('oss-cn-hangzhou.aliyuncs.com/'));

      input.bucket = 'test-bucket';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.path,
      );
      expect(hostPath, equals('oss-cn-hangzhou.aliyuncs.com/test-bucket/'));

      input.bucket = 'test-bucket';
      input.key = 'special/test-key+123';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.path,
      );
      expect(
        hostPath,
        equals(
          'oss-cn-hangzhou.aliyuncs.com/test-bucket/special/test-key%2B123',
        ),
      );

      // cname
      input = OperationInput();
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.cname,
      );
      expect(hostPath, equals('oss-cn-hangzhou.aliyuncs.com/'));

      input.bucket = 'test-bucket';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.cname,
      );
      expect(hostPath, equals('oss-cn-hangzhou.aliyuncs.com/'));

      input.bucket = 'test-bucket';
      input.key = 'special/test-key+123';
      hostPath = input.buildHostPath(
        'oss-cn-hangzhou.aliyuncs.com',
        AddressStyleType.cname,
      );
      expect(
        hostPath,
        equals('oss-cn-hangzhou.aliyuncs.com/special/test-key%2B123'),
      );
    });

    test('testQueryString', () {
      var input = OperationInput();
      var query = input.queryString();
      expect(query, equals(''));

      input = OperationInput(
        parameters: {
          'key1': 'value1+123',
          'key2+': 'value2/123',
          'key3': 'value3',
          'key4': '',
          'key5': null,
        },
      );
      query = input.queryString();
      expect(query.contains('key1=value1%2B123'), isTrue);
      expect(query.contains('key2%2B=value2%2F123'), isTrue);
      expect(query.contains('key3=value3'), isTrue);
      expect(query.contains('key4='), isTrue);
      expect(query.contains('key5='), isTrue);
    });

    test('testPresignV1Success', () async {
      const endpoint = 'oss-cn-beijing.aliyuncs.com';
      var config = Configuration.defaultConfig()
          .withSignerVersion(SignerVersion.v1)
          .withEndpoint(endpoint)
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          );
      var client = ClientImpl(config);

      var input = OperationInput(method: 'PUT');
      final expiration = DateTime.now().add(const Duration(minutes: 10));
      input.metadata.set(AttributeKeys.expirationTime, expiration);
      var result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('OSSAccessKeyId'), isTrue);
      expect(result.url!.contains('Signature'), isTrue);
      expect(result.url!.contains('Expires'), isTrue);
      expect(result.expiration, equals(expiration));

      // default expiration
      input = OperationInput(method: 'PUT');
      result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('OSSAccessKeyId'), isTrue);
      expect(result.url!.contains('Signature'), isTrue);
      expect(result.url!.contains('Expires'), isTrue);
      expect(result.expiration, isNotNull);
      expect(result.expiration!.isAfter(expiration), isTrue);

      // CredentialsProvider is null
      config = Configuration.defaultConfig()
          .withSignerVersion(SignerVersion.v1)
          .withEndpoint(endpoint);
      client = ClientImpl(config);
      input = OperationInput(method: 'PUT');
      result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('OSSAccessKeyId'), isFalse);
      expect(result.url!.contains('Signature'), isFalse);
      expect(result.url!.contains('Expires'), isFalse);
      expect(result.expiration, isNull);

      // CredentialsProvider is AnonymousCredentialsProvider
      config = Configuration.defaultConfig()
          .withSignerVersion(SignerVersion.v1)
          .withEndpoint(endpoint)
          .withCredentialsProvider(AnonymousCredentialsProvider());
      client = ClientImpl(config);
      result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('OSSAccessKeyId'), isFalse);
      expect(result.url!.contains('Signature'), isFalse);
      expect(result.url!.contains('Expires'), isFalse);
      expect(result.expiration, isNull);
    });

    test('testPresignV4Success', () async {
      const endpoint = 'oss-cn-beijing.aliyuncs.com';
      const region = 'cn-beijing';
      var config = Configuration.defaultConfig()
          .withSignerVersion(SignerVersion.v4)
          .withRegion(region)
          .withEndpoint(endpoint)
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          );
      var client = ClientImpl(config);

      var input = OperationInput(method: 'PUT');
      final expiration = DateTime.now().add(const Duration(minutes: 10));

      // default expiration
      var result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('x-oss-signature-version'), isTrue);
      expect(result.url!.contains('x-oss-expires'), isTrue);
      expect(result.url!.contains('x-oss-credential'), isTrue);
      expect(result.url!.contains('x-oss-signature'), isTrue);
      expect(result.expiration, isNotNull);
      expect(result.expiration!.isAfter(expiration), isTrue);

      // CredentialsProvider is null
      config = Configuration.defaultConfig()
          .withRegion(region)
          .withEndpoint(endpoint);
      client = ClientImpl(config);
      result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('x-oss-signature-version'), isFalse);
      expect(result.url!.contains('x-oss-expires'), isFalse);
      expect(result.url!.contains('x-oss-credential'), isFalse);
      expect(result.url!.contains('x-oss-signature'), isFalse);
      expect(result.expiration, isNull);

      // CredentialsProvider is AnonymousCredentialsProvider
      config = Configuration.defaultConfig()
          .withEndpoint(endpoint)
          .withRegion(region)
          .withCredentialsProvider(AnonymousCredentialsProvider());
      client = ClientImpl(config);
      result = await client.presignInner(input);
      expect(result.method, equals('PUT'));
      expect(result.url!.contains('x-oss-signature-version'), isFalse);
      expect(result.url!.contains('x-oss-expires'), isFalse);
      expect(result.url!.contains('x-oss-credential'), isFalse);
      expect(result.url!.contains('x-oss-signature'), isFalse);
      expect(result.expiration, isNull);
    });

    test('testPresignFail', () async {
      const endpoint = 'oss-cn-beijing.aliyuncs.com';
      const region = 'cn-beijing';

      // Credentials is null
      var config = Configuration.defaultConfig()
          .withRegion(region)
          .withEndpoint(endpoint)
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: '', accessKeySecret: ''),
          );
      var client = ClientImpl(config);
      var input = OperationInput();

      expect(
        () async => await client.presignInner(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Credentials is null or empty.'),
          ),
        ),
      );

      // expiration is error
      config = Configuration.defaultConfig()
          .withRegion(region)
          .withEndpoint(endpoint)
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          );
      client = ClientImpl(config);
      input = OperationInput();
      input.metadata.set(
        AttributeKeys.expirationTime,
        DateTime.now().add(const Duration(days: 8)),
      );

      expect(
        () async => await client.presignInner(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            contains('Expires should be not greater than 604800(seven days),'),
          ),
        ),
      );
    });

    test('testVerifyOperation', () {
      var input = OperationInput();
      input.bucket = '-bucket';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Bucket name is invalid, got -bucket.'),
          ),
        ),
      );

      input.bucket = 'bucket-';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Bucket name is invalid, got bucket-.'),
          ),
        ),
      );

      input.bucket = 'bucKet';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Bucket name is invalid, got bucKet.'),
          ),
        ),
      );

      input.bucket = '12';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Bucket name is invalid, got 12.'),
          ),
        ),
      );

      input.bucket =
          'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals(
              'Bucket name is invalid, got abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.',
            ),
          ),
        ),
      );

      input.bucket = 'bucket-name';
      expect(() => ClientImpl.verifyOperation(input), returnsNormally);

      input.key = '';
      expect(
        () => ClientImpl.verifyOperation(input),
        throwsA(
          isA<ClientError>().having(
            (e) => e.message,
            'message',
            equals('Object name is invalid, got .'),
          ),
        ),
      );

      input.key = 'key';
      expect(() => ClientImpl.verifyOperation(input), returnsNormally);
    });
  });
}

class TestRetryer implements Retryer {
  @override
  bool isErrorRetryable(Object error) {
    return false;
  }

  @override
  int maxAttempts() {
    return 1;
  }

  @override
  Duration retryDelay(int attempt, Object error) {
    return Duration.zero;
  }
}
