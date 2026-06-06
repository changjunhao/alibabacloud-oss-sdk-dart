import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatters {
  /// GMT format (for example, Tue, 29 Apr 2014 18:30:38 GMT)
  static final DateFormat rfc5322DateTime = DateFormat(
    // 'EEE, dd MMM yyyy HH:mm:ss zzz',
    "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
    'en_US',
  );

  /// iso8601 with fractional seconds, (for example, 2025-03-28T18:20:30.000Z)
  static final DateFormat iso8601DateTimeSeconds = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    'en_US',
  );

  /// iso8601 without fractional seconds, (for example, 2025-03-28T18:20:30Z)
  static final DateFormat iso8601DateTime = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
    'en_US',
  );
}

/// Extensions for DateTime
extension DateTimeExtensions on DateTime {
  /// Creates a DateTime from a string using the given formatters.
  static DateTime? fromString(String string, List<DateFormat> formatters) {
    for (final formatter in formatters) {
      try {
        return formatter.parse(string);
      } catch (e) {
        // Continue to next formatter
      }
    }
    return null;
  }
}

/// Extensions for bool
extension BoolExtensions on bool {
  String toStringValue() {
    return this ? "true" : "false";
  }
}

/// Extensions for String
extension StringExtensions on String {
  int? toInt() {
    return int.tryParse(this);
  }

  int? toUInt64() {
    // Try standard parse first (handles values <= 2^63-1)
    final result = int.tryParse(this);
    if (result != null) return result;

    // For unsigned 64-bit values > max signed int64, use BigInt
    final bigInt = BigInt.tryParse(this);
    if (bigInt == null) return null;
    if (bigInt.isNegative || bigInt.bitLength > 64) return null;

    // Convert unsigned representation to signed two's complement
    return bigInt.toSigned(64).toInt();
  }

  bool toBool() {
    final lower = toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }

  DateTime? toDate() {
    return DateTimeExtensions.fromString(this, [
      DateFormatters.rfc5322DateTime,
      DateFormatters.iso8601DateTimeSeconds,
      DateFormatters.iso8601DateTime,
    ]);
  }
}

/// Extensions for Uint8List
extension Uint8ListExtensions on Uint8List {
  Uint8List calculateMd5() {
    final digest = md5.convert(this);
    return Uint8List.fromList(digest.bytes);
  }
}

/// Extensions for Map&lt;String, dynamic&gt;
extension MapStringExtensions on Map<String, dynamic> {
  /// Case-insensitive subscript access
  dynamic getCaseInsensitive(String key) {
    // First try exact match
    if (containsKey(key)) {
      return this[key];
    }

    // Then try case-insensitive match
    final lowerKey = key.toLowerCase();
    for (final entry in entries) {
      if (entry.key.toLowerCase() == lowerKey) {
        return entry.value;
      }
    }
    return null;
  }

  /// Extract user metadata from headers
  Map<String, dynamic>? toUserMetadata() {
    final result = <String, dynamic>{};

    for (final entry in entries) {
      final lowerKey = entry.key.toLowerCase();
      if (lowerKey.startsWith('x-oss-meta-')) {
        final metaKey = lowerKey.substring(11); // Remove 'x-oss-meta-' prefix
        result[metaKey] = entry.value;
      }
    }

    return result.isNotEmpty ? result : null;
  }
}

/// Extensions for Map&lt;String, String&gt;
extension MapStringStringExtensions on Map<String, String> {
  /// Case-insensitive subscript access for String maps
  String? getCaseInsensitive(String key) {
    // First try exact match
    if (containsKey(key)) {
      return this[key];
    }

    // Then try case-insensitive match
    final lowerKey = key.toLowerCase();
    for (final entry in entries) {
      if (entry.key.toLowerCase() == lowerKey) {
        return entry.value;
      }
    }
    return null;
  }

  /// Extract user metadata from headers
  Map<String, String>? toUserMetadata() {
    final result = <String, String>{};

    for (final entry in entries) {
      final lowerKey = entry.key.toLowerCase();
      if (lowerKey.startsWith('x-oss-meta-')) {
        final metaKey = lowerKey.substring(11); // Remove 'x-oss-meta-' prefix
        result[metaKey] = entry.value;
      }
    }

    return result.isNotEmpty ? result : null;
  }
}
