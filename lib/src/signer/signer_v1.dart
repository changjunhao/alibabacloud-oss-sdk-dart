import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'signer.dart';
import 'signing_context.dart';
import 'signer_sub_resource.dart';
import '../types/request_message.dart';
import '../utils/oss_utils.dart';

/// SignerV1 implementation for OSS request signing
class SignerV1 implements Signer {
  /// The `rfc822Datetime` value.
  static final DateFormat rfc822Datetime = _createDateFormatter(
    "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
  );

  /// Create timestamp date formatter
  static DateFormat _createDateFormatter(String dateFormat) {
    final formatter = DateFormat(dateFormat, 'en_US');
    // Set timezone to UTC
    return formatter;
  }

  /// Creates a new SignerV1 instance
  const SignerV1();

  @override
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    if (signingContext.authHeader) {
      await authHeader(request, signingContext);
    } else {
      await authQuery(request, signingContext);
    }
    return request;
  }

  /// Authenticate request using header-based authentication
  Future<void> authHeader(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    // step 1
    preAuthHeader(request, signingContext);

    // step 2
    final signingKey = calcSigningKey(signingContext);

    // step 3
    final signature = calcSignature(signingKey, signingContext.stringToSign);

    // step 4
    postAuthHeader(request, signingContext, signature);
  }

  /// Authenticate request using query-based authentication
  Future<void> authQuery(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    // step 1
    preAuthQuery(request, signingContext);

    // step 2
    final signingKey = calcSigningKey(signingContext);

    // step 3
    final signature = calcSignature(signingKey, signingContext.stringToSign);

    // step 4
    postAuthQuery(request, signingContext, signature);
  }

  /// Add credential information and calc StringToSign for request
  void preAuthHeader(RequestMessage request, SigningContext context) {
    final credentials = context.credentials;
    if (credentials == null) {
      return;
    }

    final dateTime =
        context.signTime ??
        DateTime.now().add(context.clockOffset ?? Duration.zero);
    final date = rfc822Datetime.format(dateTime.toUtc());

    // add date header
    request.headers['Date'] = date;
    if (credentials.securityToken != null) {
      request.headers['x-oss-security-token'] = credentials.securityToken!;
    }

    final stringToSign = buildStringToSign(
      request,
      resourcePath(context.bucket, context.key),
      date,
      request.headers,
      context.subResource,
    );
    context.stringToSign = stringToSign;
    context.dateToSign = date;
  }

  /// Add credential information and calc StringToSign for request
  void preAuthQuery(RequestMessage request, SigningContext context) {
    final credentials = context.credentials;
    if (credentials == null) {
      return;
    }

    final expirationTime =
        context.expirationTime ??
        DateTime.now()
            .add(context.clockOffset ?? Duration.zero)
            .add(Duration(minutes: 15));
    final expiration = (expirationTime.millisecondsSinceEpoch / 1000).floor();
    context.expirationTime = expirationTime;

    final queryItems = <String, String>{};
    if (credentials.securityToken != null) {
      queryItems['security-token'] =
          credentials.securityToken!.urlEncode() ?? credentials.securityToken!;
    }
    request.requestUri = request.requestUri.appending(queryItems);

    final stringToSign = buildStringToSign(
      request,
      resourcePath(context.bucket, context.key),
      expiration.toString(),
      request.headers,
      context.subResource,
    );
    context.stringToSign = stringToSign;
    context.dateToSign = expiration.toString();
  }

  /// Update authorization header
  void postAuthHeader(
    RequestMessage request,
    SigningContext context,
    String signature,
  ) {
    final credentials = context.credentials;
    if (credentials == null) {
      return;
    }
    request.headers['Authorization'] =
        'OSS ${credentials.accessKeyId}:$signature';
  }

  /// Add authentication query parameters to request
  void postAuthQuery(
    RequestMessage request,
    SigningContext context,
    String signature,
  ) {
    final credentials = context.credentials;
    if (credentials == null) {
      return;
    }

    final queryItems = <String, String>{
      'OSSAccessKeyId':
          credentials.accessKeyId.urlEncode() ?? credentials.accessKeyId,
      'Signature': signature.urlEncode() ?? signature,
      'Expires': context.dateToSign.toString(),
    };

    request.requestUri = request.requestUri.appending(queryItems);
  }

  /// Build string to sign for signature calculation
  String buildStringToSign(
    RequestMessage request,
    String resourcePath,
    String date,
    Map<String, String> headers,
    List<String>? subResource,
  ) {
    final method = request.method;
    final contentMD5 = request.headers['Content-MD5'] ?? '';
    final contentType = request.headers['Content-Type'] ?? '';
    final canonicalizedOSSHeadersStr = canonicalizedOSSHeaders(headers);

    final queryItems = request.requestUri.queryItems;
    final canonicalizedResourceStr = canonicalizedResource(
      resourcePath,
      queryItems,
      subResource,
    );

    // Format content
    final stringToSign =
        '$method\n'
        '$contentMD5\n'
        '$contentType\n'
        '$date\n'
        '$canonicalizedOSSHeadersStr'
        '$canonicalizedResourceStr';

    return stringToSign;
  }

  /// Calculate signing key from credentials
  List<int> calcSigningKey(SigningContext context) {
    final key = context.credentials?.accessKeySecret;
    if (key == null) {
      throw Exception('Access key secret is required for signing');
    }
    return utf8.encode(key);
  }

  /// Build canonicalized OSS headers string for signature
  String canonicalizedOSSHeaders(Map<String, String> headers) {
    /// The `lowercaseHeaders` value.
    final Map<String, String> lowercaseHeaders = {};
    for (final entry in headers.entries) {
      lowercaseHeaders[entry.key.toLowerCase()] = entry.value;
    }

    final canonicalizedOSSHeaders =
        lowercaseHeaders.entries
            .where((entry) => entry.key.startsWith('x-oss-'))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final headerStrings = canonicalizedOSSHeaders
        .map((entry) => '${entry.key}:${entry.value}')
        .join('\n');

    return lowercaseHeaders.isNotEmpty ? '$headerStrings\n' : headerStrings;
  }

  /// Build canonicalized resource string for signature
  String canonicalizedResource(
    String resourcePath,
    Map<String, String>? queryItems,
    List<String>? subResource,
  ) {
    if (queryItems != null && queryItems.isNotEmpty) {
      final filteredQueries =
          queryItems.entries
              .where(
                (entry) =>
                    signerResourceFlag.contains(entry.key) ||
                    signerResponseFlag.contains(entry.key) ||
                    entry.key == signerProcessFlag ||
                    entry.key.startsWith(signerAccessFlag) ||
                    (subResource?.contains(entry.key) ?? false),
              )
              .map((entry) {
                final encodedName = entry.key.trim().urlEncode();
                if (encodedName != null) {
                  return MapEntry(encodedName, entry.value);
                }
                return null;
              })
              .where((entry) => entry != null)
              .cast<MapEntry<String, String>>()
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

      final queryStrings = filteredQueries.map((entry) {
        final encodedValue = entry.value.trim().urlEncode();
        if (encodedValue != null && encodedValue.isNotEmpty) {
          return '${entry.key}=$encodedValue';
        } else {
          return entry.key;
        }
      }).toList();

      if (queryStrings.isNotEmpty) {
        return '$resourcePath?${queryStrings.join('&')}';
      }
    }
    return resourcePath;
  }

  /// Build resource path from bucket and key
  String resourcePath(String? bucket, String? key) {
    String resourcePath = '/${bucket ?? ''}${key != null ? '/$key' : ''}';
    if (bucket != null && key == null) {
      resourcePath = '$resourcePath/';
    }
    return resourcePath;
  }

  /// Calculate signature using HMAC-SHA1
  String calcSignature(List<int> signingKey, String signToString) {
    final content = utf8.encode(signToString);
    final hmac = Hmac(sha1, signingKey);
    final digest = hmac.convert(content);
    return base64.encode(digest.bytes);
  }
}

/// Extension for Uri to provide URL query item functionality
extension UriExtension on Uri {
  /// Get query parameters as a map
  Map<String, String>? get queryItems {
    if (queryParameters.isEmpty) return null;
    return queryParameters;
  }

  /// Append query items to the URI
  Uri appending(Map<String, String> items) {
    final Map<String, String> newQueryParams = Map.from(queryParameters);
    newQueryParams.addAll(items);

    return replace(queryParameters: newQueryParams);
  }
}
