import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('SdkInfo Tests', () {
    test('testVersion', () {
      expect(SdkInfo.version, equals('1.1.0'));
    });

    test('testName', () {
      expect(SdkInfo.name, equals('alibabacloud-oss-sdk-dart'));
    });
  });
}
