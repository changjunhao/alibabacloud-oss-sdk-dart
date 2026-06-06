import 'package:mime/mime.dart';

/// Utilities for handling MIME types
class MimeUtils {
  /// Creates a MIME utility container.
  const MimeUtils();

  /// User-defined MIME type mappings that override default mappings
  static final Map<String, String> userMappings = <String, String>{};

  /// Custom MIME type resolver for additional functionality
  static final MimeTypeResolver _customResolver = MimeTypeResolver.empty();

  /// Extract file extension from a file name or path
  static String? getExtension(String fileName) {
    for (int i = fileName.length - 1; i >= 0; i--) {
      final char = fileName[i];
      if (char == '.') {
        if (i != fileName.length - 1) {
          return fileName.substring(i + 1);
        }
        return null;
      } else if (char == '/' || char == '\\' || char == ':') {
        break;
      }
    }
    return null;
  }

  /// Get MIME type from file name
  ///
  /// [fileName] - The file name or path
  /// [defaultMimeType] - Default MIME type to return if no match found
  ///
  /// Returns the MIME type string or null if not found and no default provided
  static String? getMimeType(String fileName, {String? defaultMimeType}) {
    final pathExtension = getExtension(fileName);
    if (pathExtension == null) {
      return defaultMimeType;
    }
    return getMimeTypeFromExtension(
      pathExtension,
      defaultMimeType: defaultMimeType,
    );
  }

  /// Get MIME type from URI
  ///
  /// [uri] - The URI object
  /// [defaultMimeType] - Default MIME type to return if no match found
  ///
  /// Returns the MIME type string or null if not found and no default provided
  static String? getMimeTypeFromUri(Uri uri, {String? defaultMimeType}) {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      return defaultMimeType;
    }
    final fileName = pathSegments.last;
    return getMimeType(fileName, defaultMimeType: defaultMimeType);
  }

  /// Get MIME type from file extension
  ///
  /// [pathExtension] - The file extension (without dot)
  /// [defaultMimeType] - Default MIME type to return if no match found
  ///
  /// Returns the MIME type string or null if not found and no default provided
  static String? getMimeTypeFromExtension(
    String pathExtension, {
    String? defaultMimeType,
  }) {
    final extension = pathExtension.toLowerCase();

    // Try to get MIME type from user mappings first
    if (userMappings.containsKey(extension)) {
      return userMappings[extension];
    }

    // Try custom resolver
    final customResult = _customResolver.lookup('file.$extension');
    if (customResult != null) {
      return customResult;
    }

    // Try system/built-in resolver
    final systemResult = lookupMimeType('file.$extension');
    if (systemResult != null) {
      return systemResult;
    }

    return defaultMimeType;
  }

  /// Get MIME type from file content (magic bytes)
  ///
  /// [fileName] - The file name (for extension fallback)
  /// [headerBytes] - The first few bytes of the file content
  /// [defaultMimeType] - Default MIME type to return if no match found
  ///
  /// Returns the MIME type string or null if not found and no default provided
  static String? getMimeTypeFromContent(
    String fileName,
    List<int> headerBytes, {
    String? defaultMimeType,
  }) {
    // Try custom resolver first (for custom magic numbers)
    final customResult = _customResolver.lookup(
      fileName,
      headerBytes: headerBytes,
    );
    if (customResult != null) {
      return customResult;
    }

    // Try built-in magic bytes detection
    final magicResult = lookupMimeType(fileName, headerBytes: headerBytes);
    if (magicResult != null) {
      return magicResult;
    }

    // Fallback to extension-based detection
    return getMimeType(fileName, defaultMimeType: defaultMimeType);
  }

  /// Add a custom MIME type mapping
  ///
  /// [extension] - File extension (without dot)
  /// [mimeType] - MIME type string
  static void addExtensionMapping(String extension, String mimeType) {
    userMappings[extension.toLowerCase()] = mimeType;
  }

  /// Add a custom magic number mapping
  ///
  /// [magicBytes] - The magic bytes to match
  /// [mimeType] - MIME type string
  /// [mask] - Optional mask for magic bytes matching
  static void addMagicNumberMapping(
    List<int> magicBytes,
    String mimeType, {
    List<int>? mask,
  }) {
    _customResolver.addMagicNumber(magicBytes, mimeType, mask: mask);
  }

  /// Remove a custom extension mapping
  ///
  /// [extension] - File extension to remove
  static void removeExtensionMapping(String extension) {
    userMappings.remove(extension.toLowerCase());
  }

  /// Clear all custom mappings
  static void clearCustomMappings() {
    userMappings.clear();
  }

  /// Get file extension from MIME type (reverse lookup)
  ///
  /// [mimeType] - The MIME type string
  ///
  /// Returns the file extension (without dot) or null if not found
  static String? getExtensionFromMimeType(String mimeType) {
    final normalizedMimeType = mimeType.toLowerCase();

    // Check user mappings first
    for (final entry in userMappings.entries) {
      if (entry.value.toLowerCase() == normalizedMimeType) {
        return entry.key;
      }
    }

    // Use built-in reverse lookup
    try {
      final result = extensionFromMime(mimeType);
      // Handle special cases where we want to return more common extensions
      if (result == 'jpg' && normalizedMimeType == 'image/jpeg') {
        return 'jpeg';
      }
      return result == mimeType ? null : result;
    } catch (e) {
      return null;
    }
  }
}
