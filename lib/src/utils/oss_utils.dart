import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alibabacloud_oss_sdk_dart/src/enums.dart';

/// OSS utility functions
class OSSUtils {
  /// Creates an OSS utility container.
  const OSSUtils();

  /// Convert region to endpoint based on endpoint type
  static String regionToEndpoint(String region, EndpointType type) {
    switch (type) {
      case EndpointType.defautt:
        return 'oss-$region.aliyuncs.com';
      case EndpointType.internal:
        return 'oss-$region-internal.aliyuncs.com';
      case EndpointType.accelerate:
        return 'oss-accelerate.aliyuncs.com';
      case EndpointType.dualstack:
        return '$region.oss.aliyuncs.com';
      case EndpointType.overseas:
        return 'oss-accelerate-overseas.aliyuncs.com';
    }
  }
}

/// String extensions for OSS utilities
extension StringOSSExtensions on String {
  /// URL encode string with OSS allowed characters
  String? urlEncode() {
    final ossAllowed = _getOssAllowedCharacters();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final char = this[i];
      if (ossAllowed.contains(char)) {
        buffer.write(char);
      } else {
        final bytes = utf8.encode(char);
        for (final byte in bytes) {
          buffer.write(
            '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
          );
        }
      }
    }

    return buffer.toString();
  }

  /// URL encode path with OSS allowed characters including '/'
  String? urlEncodePath() {
    final ossAllowed = '${_getOssAllowedCharacters()}/';
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final char = this[i];
      if (ossAllowed.contains(char)) {
        buffer.write(char);
      } else {
        final bytes = utf8.encode(char);
        for (final byte in bytes) {
          buffer.write(
            '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
          );
        }
      }
    }

    return buffer.toString();
  }

  /// URL encode without separator (allows '/' to pass through)
  String? urlEncodeWithoutSeparator() {
    final ossAllowed = '${_getOssAllowedCharacters()}/';
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final char = this[i];
      if (ossAllowed.contains(char)) {
        buffer.write(char);
      } else {
        final bytes = utf8.encode(char);
        for (final byte in bytes) {
          buffer.write(
            '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
          );
        }
      }
    }

    return buffer.toString();
  }

  /// Check if string matches a pattern
  bool _isValid(String pattern) {
    try {
      final regex = RegExp(pattern);
      return regex.hasMatch(this);
    } catch (e) {
      return false;
    }
  }

  /// Validate bucket name
  bool isValidBucketName() {
    return _isValid(Pattern.bucketNamePattern.value);
  }

  /// Validate object key
  bool isValidObjectKey() {
    return length >= 1 && length <= 1024;
  }

  /// Escape XML special characters
  String escape() {
    // Note: & must be replaced first to avoid double-escaping
    return replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Trim whitespace and newlines
  String trimWhitespace() {
    return trim();
  }

  /// Check if string is an IP address (IPv4 or IPv6)
  bool isIPAddress() {
    try {
      final address = InternetAddress(this);
      return address.type == InternetAddressType.IPv4 ||
          address.type == InternetAddressType.IPv6;
    } catch (e) {
      return false;
    }
  }

  /// Get OSS allowed characters
  static String _getOssAllowedCharacters() {
    const ranges = [
      'abcdefghijklmnopqrstuvwxyz',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      '0123456789',
      '.~-_',
    ];
    return ranges.join();
  }
}

/// Map extensions for OSS utilities
extension MapOSSExtensions on Map<String, dynamic> {
  /// Convert map to base64 JSON string
  String toBase64JsonString() {
    try {
      final jsonString = jsonEncode(this).replaceAll('\\/', '/');
      final bytes = utf8.encode(jsonString);
      return base64Encode(bytes);
    } catch (e) {
      // Return empty JSON object in base64
      return 'e30=';
    }
  }

  /// Encode map as query string
  String encodedQuery() {
    final queryParameters = <String>[];

    for (final entry in entries) {
      final key = entry.key;
      final value = entry.value?.toString() ?? '';

      final encodedKey = key.urlEncode();
      final encodedValue = value.urlEncode();

      if (encodedKey != null && encodedValue != null) {
        final parameter = encodedValue.isEmpty
            ? encodedKey
            : '$encodedKey=$encodedValue';
        queryParameters.add(parameter);
      }
    }

    return queryParameters.join('&');
  }
}

/// Uint8List extensions for OSS utilities
extension Uint8ListOSSExtensions on Uint8List {
  /// Convert Uint8List to base64 string
  String toBase64String() {
    return base64Encode(this);
  }
}

/// Case insensitive string implementation
class CaseInsensitiveString {
  /// The original string value used for case-insensitive comparison.
  final String value;

  /// Creates a case-insensitive string wrapper.
  const CaseInsensitiveString(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseInsensitiveString &&
        value.toLowerCase() == other.value.toLowerCase();
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => value.toLowerCase().hashCode;

  @override
  String toString() => value;
}
