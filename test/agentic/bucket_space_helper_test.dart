import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  test('helper supports explicit configuration and configuration snapshot', () {
    const helper = BucketSpaceHelper(accountId: '00137', region: 'cn-hangzhou');
    expect(helper.toBucketName('prefix'), 'prefix-00137-cn-hangzhou-bs-apsr');
    final config = Configuration(accountId: '00137', region: 'cn-hangzhou');
    final snapshot = BucketSpaceHelper.fromConfiguration(config);
    config.accountId = '999';
    expect(snapshot.toBucketName('prefix'), helper.toBucketName('prefix'));
  });
  test('helper only concatenates, does not validate configuration early', () {
    expect(
      BucketSpaceHelper.fromConfiguration(
        Configuration(),
      ).toBucketName('prefix'),
      'prefix---bs-apsr',
    );
  });
}
