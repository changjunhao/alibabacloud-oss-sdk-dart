import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class UnitTestError implements Exception {
  final String message;
  UnitTestError(this.message);

  @override
  String toString() => 'UnitTestError: $message';
}

class Utils {
  static final String tempDir =
      '${Directory.systemTemp.path}${Platform.pathSeparator}dart-sdk-test_${_generateUuid()}';
  static final String pathSeparator = Platform.pathSeparator;

  static String _generateUuid() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<Uint8List> calculateMd5({required String fileURL}) async {
    try {
      final file = File(fileURL);
      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes);
      return Uint8List.fromList(digest.bytes);
    } catch (error) {
      throw UnitTestError('Cannot open file: ${error.toString()}');
    }
  }

  static Future<String?> createTestFile(
    String fileName,
    Uint8List contents,
  ) async {
    try {
      final filePath = '$tempDir$pathSeparator$fileName';
      final directory = Directory(tempDir);
      await directory.create(recursive: true);

      final file = File(filePath);
      if (await file.exists()) {
        await removeTestFile(filePath);
      }

      await file.writeAsBytes(contents);
      return filePath;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  static Future<String?> createTestFileWithSize(
    String fileName,
    int size,
  ) async {
    try {
      final filePath = '$tempDir$pathSeparator$fileName';
      final directory = Directory(tempDir);
      await directory.create(recursive: true);

      final contents = utf8.encode(randomStr(size));
      final file = File(filePath);
      if (await file.exists()) {
        await removeTestFile(filePath);
      }

      await file.writeAsBytes(contents);
      return filePath;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  static Future<void> removeTestFile(String location) async {
    try {
      final file = File(location);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      // Ignore errors when removing test files
    }
  }

  static const String _randomStrChar = 'abcdefghijklmnopqrstuvwxyz';

  static String randomStr(int length) {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final index = random.nextInt(_randomStrChar.length);
      buffer.write(_randomStrChar[index]);
    }
    return buffer.toString();
  }
}

final String fileDir = Directory.systemTemp.path;

enum FileName {
  small,
  middle,
  big,
  picture;

  String filePath() {
    return path.join(fileDir, name);
  }

  String fileUrl() {
    return filePath();
  }
}

class ArrayActor<T> {
  final List<T> _elements = <T>[];

  List<T> get elements => List.unmodifiable(_elements);

  void append(T element) {
    _elements.add(element);
  }
}

Future<void> expectAsyncError<T>(
  Future<T> Function() expression, {
  String message = '',
  void Function(Object error)? errorHandler,
}) async {
  try {
    await expression();
    // Expected error to be thrown, but it was not
    final customMessage = message.isEmpty
        ? 'Asynchronous call did not throw an error.'
        : message;
    fail(customMessage);
  } catch (error) {
    if (errorHandler != null) {
      errorHandler(error);
    }
  }
}

Future<void> expectNoAsyncError<T>(Future<T> Function() expression) async {
  try {
    await expression();
  } catch (error) {
    fail('Threw an error: $error');
  }
}

class ValueActor {
  int _value = 0;

  void setValue(int value) {
    _value = value;
  }

  void increment() {
    _value += 1;
  }

  int getV() {
    return _value;
  }
}

extension DataExtension on Uint8List {
  String toBase64String() {
    return base64Encode(this);
  }
}
