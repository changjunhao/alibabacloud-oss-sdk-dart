import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/attributes.dart';

void main() {
  group('Attributes Tests', () {
    const strKey = AttributeKey<String>(name: 'key-string');

    test('testSetAndGetValue', () {
      final subject = Attributes();

      subject.set(strKey, '123');

      expect(subject.get(strKey), equals('123'));
    });

    test('testSetAndGetArrayValue', () {
      final subject = Attributes();

      subject.setValues(strKey, ['123', '456']);
      expect(subject.get(strKey), equals('123'));

      final vals = subject.values(strKey);
      expect(vals, isNotNull);
      expect(vals!.length, equals(2));
      expect(vals[0], equals('123'));
      expect(vals[1], equals('456'));
    });

    test('testSetAndGetValues', () {
      var subject = Attributes();
      subject.set(strKey, '123');
      var vals = subject.values(strKey);
      expect(vals, isNotNull);
      expect(vals!.length, equals(1));
      expect(vals[0], equals('123'));

      subject = Attributes();
      subject.append(strKey, '1234');
      vals = subject.values(strKey);
      expect(vals, isNotNull);
      expect(vals!.length, equals(1));
      expect(vals[0], equals('1234'));

      subject = Attributes();
      subject.set(strKey, '123');
      subject.append(strKey, '456');
      vals = subject.values(strKey);
      expect(vals, isNotNull);
      expect(vals!.length, equals(2));
      expect(vals[0], equals('123'));
      expect(vals[1], equals('456'));
    });

    test('testContains', () {
      final subject = Attributes();
      expect(subject.contains(strKey), isFalse);

      subject.set(strKey, '123');
      expect(subject.contains(strKey), isTrue);
    });

    test('testRemove', () {
      final subject = Attributes();
      subject.set(strKey, '123');

      subject.remove(strKey);
      expect(subject.get(strKey), isNull);
    });
  });
}