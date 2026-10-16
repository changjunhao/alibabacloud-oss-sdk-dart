import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('Configuration Tests', () {
    test(
      'Default, chained, and copy configuration for accountId and alias',
      () {
        final defaults = Configuration();
        expect(defaults.accountId, isNull);
        expect(defaults.useVirtualHostedAlias, isNull);
        final config = defaults
            .withAccountId('00137')
            .withUseVirtualHostedAlias(true);
        final copy = config.copyWith();
        expect(copy, config);
        expect(copy.hashCode, config.hashCode);
        expect(copy.accountId, '00137');
        expect(copy.useVirtualHostedAlias, isTrue);
        expect(config.copyWith(accountId: '2'), isNot(config));
        expect(config.copyWith(useVirtualHostedAlias: false), isNot(config));
        expect(config.toString(), isNot(contains('00137')));
        expect(
          Configuration(accountId: '00137', useVirtualHostedAlias: true),
          config,
        );
      },
    );

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
