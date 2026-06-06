import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:path/path.dart' as path;

void main() {
  group('ByteStream Tests', () {
    setUp(() {
      // Put setup code here. This method is called before the invocation of each test method in the group.
    });

    tearDown(() {
      // Put teardown code here. This method is called after the invocation of each test method in the group.
    });

    test('testIsSeekable', () {
      var b = ByteStream.none;
      expect(b.isSeekable, isTrue);

      b = ByteStream.fromData(Uint8List(0));
      expect(b.isSeekable, isTrue);

      b = ByteStream.fromFile(File('/tmp/test.txt'));
      expect(b.isSeekable, isTrue);

      b = ByteStream.fromStream(Stream.fromIterable([]));
      expect(b.isSeekable, isFalse);
    });

    test('testReadDataAndGetBodyLength', () async {
      var b = ByteStream.none;
      var got = await b.readData();
      var len = await b.getBodyLength();
      expect(got, isNull);
      expect(len, equals(0));

      var data = Uint8List.fromList('hello oss'.codeUnits);
      b = ByteStream.fromData(data);
      got = await b.readData();
      len = await b.getBodyLength();
      expect(got, equals(data));
      expect(len, equals(9));

      data = Uint8List.fromList('hello oss 1'.codeUnits);
      final tempDir = Directory.systemTemp;
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = File(path.join(tempDir.path, 'test_$uniqueId.txt'));

      // not exist
      b = ByteStream.fromFile(url);
      try {
        got = await b.readData();
        fail('should not reach here');
      } catch (error) {
        expect(error, isNotNull);
      }
      try {
        len = await b.getBodyLength();
        fail('should not reach here');
      } catch (error) {
        expect(error, isNotNull);
      }

      // exist
      await url.writeAsBytes(data);

      try {
        b = ByteStream.fromFile(url);
        got = await b.readData();
        len = await b.getBodyLength();
        expect(got, equals(data));
        expect(len, equals(11));
      } finally {
        // cleanup
        if (await url.exists()) {
          await url.delete();
        }
      }

      b = ByteStream.fromStream(Stream.fromIterable([data]));
      try {
        len = await b.getBodyLength();
        expect(len, isNull);
        got = await b.readData();
        fail('should not reach here');
      } catch (error) {
        expect(
          error.toString(),
          contains('Stream for body not supported read'),
        );
      }
    });

    test('testHashcrc64', () async {
      // none
      final none = ByteStream.none;
      final noneHash = await none.hashCrc64ecma();
      expect(noneHash, equals(0));

      // data
      final b = ByteStream.fromData(Uint8List.fromList('123456789'.codeUnits));
      final hash = await b.hashCrc64ecma();
      expect(hash, equals(0x995DC9BBDF1939FA));

      final b1 = ByteStream.fromData(Uint8List.fromList('987654321'.codeUnits));
      final hash1 = await b1.hashCrc64ecma();
      expect(hash1, equals(0xE7ADEF3D663C7E22));

      // file
      final tempDir = Directory.systemTemp;
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final url = File(path.join(tempDir.path, 'test_crc_$uniqueId.txt'));
      await url.writeAsBytes(Uint8List.fromList('123456789'.codeUnits));

      try {
        final file = ByteStream.fromFile(url);
        final fileHash = await file.hashCrc64ecma();
        expect(fileHash, equals(0x995DC9BBDF1939FA));
      } finally {
        // cleanup
        if (await url.exists()) {
          await url.delete();
        }
      }

      // stream
      final stream = ByteStream.fromStream(
        Stream.fromIterable([Uint8List.fromList('123456789'.codeUnits)]),
      );
      final streamHash = await stream.hashCrc64ecma();
      expect(streamHash, isNull);
    });
  });
}
