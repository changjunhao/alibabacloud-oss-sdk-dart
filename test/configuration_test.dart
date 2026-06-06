import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('Configuration Tests', () {
    test('testConfigurationConstructor', () {
      final config = Configuration.defaultConfig();
      expect(config, isNotNull);
      expect(config.endpoint, isNull);
      expect(config.credentialsProvider, isNull);
    });

    test('testConfigurationWithFunc', () {
      final config = Configuration.defaultConfig();
      expect(config, isNotNull);
      expect(config.endpoint, isNull);
      expect(config.credentialsProvider, isNull);

      config
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(const AnonymousCredentialsProvider())
          .withEndpoint('http://oss-cn-hangzhou.aliyuncs.com');

      expect(config.endpoint, equals('http://oss-cn-hangzhou.aliyuncs.com'));
      expect(config.region, equals('cn-hangzhou'));
      expect(config.credentialsProvider, isNotNull);
    });
  });
}
