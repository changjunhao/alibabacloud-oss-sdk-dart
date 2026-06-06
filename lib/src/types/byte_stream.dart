import 'dart:io';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/src/utils/crc64.dart';

/// Exception types for ByteStream operations
class ByteStreamException implements Exception {
  /// The error message associated with the byte stream failure.
  final String message;

  /// Creates a byte stream exception with the given message.
  const ByteStreamException(this.message);

  @override
  String toString() => 'ByteStreamException: $message';
}

/// The `FileForBodyNotFoundException` file for body not found exception.
class FileForBodyNotFoundException extends ByteStreamException {
  /// Creates a FileForBodyNotFoundException instance.
  const FileForBodyNotFoundException() : super('File for body not found');
}

/// The `StreamForBodyNotSupportedReadException` stream for body not supported read exception.
class StreamForBodyNotSupportedReadException extends ByteStreamException {
  /// Creates a StreamForBodyNotSupportedReadException instance.
  const StreamForBodyNotSupportedReadException()
    : super('Stream for body not supported read');
}

/// ByteStream represents different types of data sources for HTTP request bodies
abstract class ByteStream {
  /// Creates a byte stream abstraction.
  const ByteStream();

  /// Creates an empty ByteStream
  static ByteStream get empty => DataByteStream(Uint8List(0));

  /// Creates a ByteStream from Data
  factory ByteStream.fromData(Uint8List data) => DataByteStream(data);

  /// Creates a ByteStream from a file
  factory ByteStream.fromFile(File file) => FileByteStream(file);

  /// Creates a ByteStream from a Stream
  factory ByteStream.fromStream(Stream<List<int>> stream) =>
      StreamByteStream(stream);

  /// Creates a null/none ByteStream
  static const ByteStream none = NoneByteStream();

  /// Returns true if the byte stream is seekable
  bool get isSeekable;

  /// Returns the body length, or null for streams
  Future<int?> getBodyLength();

  /// Read all data from the stream
  Future<Uint8List?> readData();

  /// Calculate CRC64 hash of the data
  Future<int?> hashCrc64ecma({int crc = 0});
}

/// ByteStream implementation for no data
class NoneByteStream extends ByteStream {
  /// Creates a NoneByteStream instance.
  const NoneByteStream();

  @override
  /// Returns the `isSeekable` value.
  bool get isSeekable => true;

  @override
  Future<int?> getBodyLength() async => 0;

  @override
  Future<Uint8List?> readData() async => null;

  @override
  Future<int?> hashCrc64ecma({int crc = 0}) async => 0;
}

/// ByteStream implementation for in-memory data
class DataByteStream extends ByteStream {
  /// The `data` value.
  final Uint8List data;

  /// Creates a DataByteStream instance.
  const DataByteStream(this.data);

  @override
  /// Returns the `isSeekable` value.
  bool get isSeekable => true;

  @override
  Future<int?> getBodyLength() async => data.length;

  @override
  Future<Uint8List?> readData() async => data;

  @override
  Future<int?> hashCrc64ecma({int crc = 0}) async {
    return CRC64.defaultInstance.crc64(crc, data);
  }
}

/// ByteStream implementation for file data
class FileByteStream extends ByteStream {
  /// The `file` value.
  final File file;

  /// Creates a FileByteStream instance.
  const FileByteStream(this.file);

  @override
  /// Returns the `isSeekable` value.
  bool get isSeekable => true;

  @override
  Future<int?> getBodyLength() async {
    if (!await file.exists()) {
      throw const FileForBodyNotFoundException();
    }
    try {
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      throw const FileForBodyNotFoundException();
    }
  }

  @override
  Future<Uint8List?> readData() async {
    if (!await file.exists()) {
      throw const FileForBodyNotFoundException();
    }
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw const FileForBodyNotFoundException();
    }
  }

  @override
  Future<int?> hashCrc64ecma({int crc = 0}) async {
    try {
      final stream = file.openRead();
      var currentCrc = crc;
      // const bufferSize = 16 * 1024; // Reserved for future use

      await for (final chunk in stream) {
        final uint8Chunk = Uint8List.fromList(chunk);
        currentCrc = CRC64.defaultInstance.crc64(currentCrc, uint8Chunk);
      }

      return currentCrc;
    } catch (e) {
      return null;
    }
  }
}

/// ByteStream implementation for stream data
class StreamByteStream extends ByteStream {
  /// The `stream` value.
  final Stream<List<int>> stream;

  /// Creates a StreamByteStream instance.
  const StreamByteStream(this.stream);

  @override
  /// Returns the `isSeekable` value.
  bool get isSeekable => false;

  @override
  Future<int?> getBodyLength() async => null;

  @override
  Future<Uint8List?> readData() async {
    throw const StreamForBodyNotSupportedReadException();
  }

  @override
  Future<int?> hashCrc64ecma({int crc = 0}) async => null;
}
