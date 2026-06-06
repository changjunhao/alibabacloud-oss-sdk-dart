import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('Client Tests', () {
    setUp(() {
      // Put setup code here. This method is called before the invocation of each test method in the group.
    });

    tearDown(() {
      // Put teardown code here. This method is called after the invocation of each test method in the group.
    });

    test('testClientConstructor', () {
      final credentialsProvider = const AnonymousCredentialsProvider();
      const endpoint = 'oss-cn-hangzhou.aliyuncs.com';
      final config = Configuration.defaultConfig()
          .withEndpoint(endpoint)
          .withCredentialsProvider(credentialsProvider);

      var client = Client(config);
      expect(client, isNotNull);

      // Test client creation with different configurations
      // Note: Since _clientImpl is private, we test the client creation behavior
      client = Client(config, [(options) => options.region = 'cn-hangzhou']);
      expect(client, isNotNull);

      client = Client(config, [
        (options) => options.region = 'cn-hangzhou',
        (options) => options.region = 'cn-beijing',
      ]);
      expect(client, isNotNull);
    });

    test('testClientFeatureFlags', () {
      final credentialsProvider = const AnonymousCredentialsProvider();
      const endpoint = 'oss-cn-hangzhou.aliyuncs.com';
      final config = Configuration.defaultConfig()
          .withEndpoint(endpoint)
          .withCredentialsProvider(credentialsProvider);

      final client = Client(config);
      expect(client, isNotNull);

      // Test that client has feature flags enabled
      // Note: We can't access the raw value directly since _clientImpl is private

      expect(client.hasFeatureFlag(FeatureFlag.correctClockSkew), isTrue);
      expect(client.hasFeatureFlag(FeatureFlag.autoDetectMimeType), isTrue);
      expect(
        client.hasFeatureFlag(FeatureFlag.enableCRC64CheckDownload),
        isTrue,
      );
      expect(client.hasFeatureFlag(FeatureFlag.enableCRC64CheckUpload), isTrue);

      expect(client.hasFeatureFlag(FeatureFlag.enableMD5), isFalse);
    });
  });
}
