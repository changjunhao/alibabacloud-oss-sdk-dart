import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'signer.dart';
import 'signing_context.dart';
import '../types/request_message.dart';
import '../utils/oss_utils.dart';

/// SignerV4 implementation for OSS request signing
class SignerV4 implements Signer {
  static final DateFormat rfc822Datetime = _createDateFormatter(
    "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
  );
  static final DateFormat iso8601Datetime = _createDateFormatter(
    "yyyyMMdd'T'HHmmss'Z'",
  );

  /// Create timestamp date formatter
  static DateFormat _createDateFormatter(String dateFormat) {
    final formatter = DateFormat(dateFormat, 'en_US');
    // Set timezone to UTC
    return formatter;
  }

  /// Creates a new SignerV4 instance
  const SignerV4();

  @override
  Future<RequestMessage> sign(
    RequestMessage request,
    SigningContext signingContext,
  ) async {
    var requestCopy = request;
    if (signingContext.authHeader) {
      authHeader(requestCopy, signingContext);
    } else {
      authQuery(requestCopy, signingContext);
    }
    return requestCopy;
  }

  /// Calculate canonical request
  String calcCanonicalRequest(
    RequestMessage request,
    String resourcePath,
    Map<String, String> headers,
    List<String> additionalHeaders,
  ) {
    /*
     Canonical Request
     HTTP Verb + "\n" +
     Canonical URI + "\n" +
     Canonical Query String + "\n" +
     Canonical Headers + "\n" +
     Additional Headers + "\n" +
     Hashed PayLoad
     */
    final verb = request.method.toUpperCase();

    final canonicalUri = resourcePath.urlEncodeWithoutSeparator() ?? '';

    final String canonicalQueries;
    final queryParameters = request.requestUri.queryParameters;
    if (queryParameters.isNotEmpty) {
      final sortedParams =
          queryParameters.entries
              .map(
                (entry) => {
                  'name': entry.key.urlEncode() ?? '',
                  'value': entry.value.urlEncode(),
                },
              )
              .toList()
            ..sort((a, b) => a['name']!.compareTo(b['name']!));

      canonicalQueries = sortedParams
          .map((param) {
            final name = param['name']!;
            final value = param['value'];
            if (value != null && value.isNotEmpty) {
              return '$name=$value';
            }
            return name;
          })
          .join('&');
    } else {
      canonicalQueries = '';
    }

    final filteredHeaders =
        headers.entries
            .where((entry) {
              final key = entry.key;
              return key == 'content-md5' ||
                  key == 'content-type' ||
                  key.startsWith('x-oss-') ||
                  additionalHeaders.contains(key);
            })
            .map(
              (entry) => {
                'key': entry.key,
                'value': entry.value.trimWhitespace(),
              },
            )
            .toList()
          ..sort((a, b) => a['key']!.compareTo(b['key']!));

    final canonicalHeaders = filteredHeaders
        .map((header) => '${header['key']}:${header['value']}\n')
        .join('');

    final canonicalAdditionalHeaders = (additionalHeaders.toList()..sort())
        .join(';');

    final hashedPayLoad = headers['x-oss-content-sha256'] ?? 'UNSIGNED-PAYLOAD';

    final canonicalRequest =
        '$verb\n'
        '$canonicalUri\n'
        '$canonicalQueries\n'
        '$canonicalHeaders\n'
        '$canonicalAdditionalHeaders\n'
        '$hashedPayLoad';

    // print('canonicalRequest:\n$canonicalRequest\n');

    return canonicalRequest;
  }

  /// Calculate string to sign
  String calcStringToSign(
    String datetime,
    String scope,
    String canonicalRequest,
  ) {
    /*
     StringToSign
     "OSS4-HMAC-SHA256" + "\n" +
     TimeStamp + "\n" +
     Scope + "\n" +
     Hex(SHA256Hash(Canonical Request))
     */
    final digest = sha256.convert(canonicalRequest.codeUnits);
    final hexDigest = digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    final stringToSign = 'OSS4-HMAC-SHA256\n$datetime\n$scope\n$hexDigest';

    // print('stringToSign:\n$stringToSign\n');
    return stringToSign;
  }

  /// Build resource path from bucket and key
  String resourcePath(String? bucket, String? key) {
    var resourcePath = '/${bucket ?? ''}${key != null ? '/$key' : ''}';
    if (bucket != null && key == null) {
      resourcePath = '$resourcePath/';
    }
    return resourcePath;
  }

  /// Calculate signing key using HMAC-SHA256
  List<int> calcSigningKey(SigningContext context) {
    final region = context.region ?? '';
    final product = context.product ?? '';

    // kDate = HMAC-SHA256("aliyun_v4" + accessKeySecret, dateToSign)
    final kDate = Hmac(
      sha256,
      'aliyun_v4${context.credentials!.accessKeySecret}'.codeUnits,
    ).convert(context.dateToSign.codeUnits);

    // kRegion = HMAC-SHA256(kDate, region)
    final kRegion = Hmac(sha256, kDate.bytes).convert(region.codeUnits);

    // kProduct = HMAC-SHA256(kRegion, product)
    final kProduct = Hmac(sha256, kRegion.bytes).convert(product.codeUnits);

    // kSigning = HMAC-SHA256(kProduct, "aliyun_v4_request")
    final kSigning = Hmac(
      sha256,
      kProduct.bytes,
    ).convert('aliyun_v4_request'.codeUnits);

    return kSigning.bytes;
  }

  /// Calculate signature using HMAC-SHA256
  String calcSignature(List<int> signingKey, String signToString) {
    final hmac = Hmac(sha256, signingKey);
    final digest = hmac.convert(signToString.codeUnits);
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Add credential information and calculate StringToSign for request
  void preAuthQuery(RequestMessage request, SigningContext context) {
    final cred = context.credentials!;
    final region = context.region ?? '';
    final product = context.product ?? '';

    // Date
    final clockOffsetMs = context.clockOffset is Duration
        ? (context.clockOffset as Duration).inMilliseconds
        : (context.clockOffset as int? ?? 0) * 1000;
    final signTime =
        context.signTime ??
        DateTime.now().add(Duration(milliseconds: clockOffsetMs));
    final datetime = iso8601Datetime.format(signTime.toUtc());
    final date = datetime.substring(0, 8);

    // Expiration
    final expiration =
        context.expirationTime ?? signTime.add(Duration(minutes: 15));
    final expires = expiration.difference(signTime).inSeconds;
    context.expirationTime = expiration;

    // Scope
    final scope = '$date/$region/$product/aliyun_v4_request';

    // Lowercase request headers
    final headers = <String, String>{};
    for (final entry in request.headers.entries) {
      headers[entry.key.toLowerCase()] = entry.value;
    }

    // Lowercase additional headers
    final additionalSignedHeaders = <String>[];
    context.additionalHeaderNames?.forEach((key) {
      final lowkey = key.toLowerCase();
      if (!(lowkey == 'content-md5' ||
              lowkey == 'content-type' ||
              lowkey.startsWith('x-oss-')) &&
          headers.containsKey(lowkey)) {
        additionalSignedHeaders.add(lowkey);
      }
    });

    // Credential information signature
    var query = request.requestUri.query;
    if (query.isNotEmpty) {
      query += '&';
    }
    query += 'x-oss-signature-version=OSS4-HMAC-SHA256';
    query += '&x-oss-date=$datetime';
    query += '&x-oss-expires=$expires';
    final credentialQuery = '${cred.accessKeyId}/$scope';
    query += '&x-oss-credential=${credentialQuery.urlEncode()!}';

    if (additionalSignedHeaders.isNotEmpty) {
      additionalSignedHeaders.sort();
      final addHeaderStr = additionalSignedHeaders.join(';');
      query += '&x-oss-additional-headers=${addHeaderStr.urlEncode()!}';
    }

    if (cred.securityToken?.isNotEmpty == true) {
      query += '&x-oss-security-token=${cred.securityToken!.urlEncode()!}';
    }

    // Rebuild URI with new query
    final baseUrl = request.requestUri.toString().split('?')[0];
    request.requestUri = Uri.parse('$baseUrl?$query');

    // CanonicalRequest
    final canonicalRequest = calcCanonicalRequest(
      request,
      resourcePath(context.bucket, context.key),
      headers,
      additionalSignedHeaders,
    );

    // StringToSign
    context.stringToSign = calcStringToSign(datetime, scope, canonicalRequest);
    context.dateToSign = date;
    context.scopeToSign = scope;
    additionalSignedHeaders.sort();
    context.additionalHeadersToSign = additionalSignedHeaders.join(';');
  }

  /// Add signature to request query parameters
  void postAuthQuery(
    RequestMessage request,
    SigningContext context,
    String signature,
  ) {
    final uri = request.requestUri;
    final existingQuery = uri.query;

    // Add signature to query parameters
    final newQuery = existingQuery.isEmpty
        ? 'x-oss-signature=$signature'
        : '$existingQuery&x-oss-signature=$signature';

    // Rebuild URI with new query
    final newUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      query: newQuery,
    );

    request.requestUri = newUri;
  }

  /// Add credential information and calculate StringToSign for request
  void preAuthHeader(RequestMessage request, SigningContext context) {
    final cred = context.credentials!;
    final region = context.region ?? '';
    final product = context.product ?? '';

    // Date
    final clockOffsetMs = context.clockOffset is Duration
        ? (context.clockOffset as Duration).inMilliseconds
        : (context.clockOffset as int? ?? 0) * 1000;
    final signTime =
        context.signTime ??
        DateTime.now().add(Duration(milliseconds: clockOffsetMs));
    final datetime = iso8601Datetime.format(signTime.toUtc());
    final date = datetime.substring(0, 8);
    final datetimeGmt = rfc822Datetime.format(signTime.toUtc());

    // Scope
    final scope = '$date/$region/$product/aliyun_v4_request';

    // Credential information signature
    if (cred.securityToken?.isNotEmpty == true) {
      request.headers['x-oss-security-token'] = cred.securityToken!;
    }

    // Other Headers
    request.headers['x-oss-content-sha256'] = 'UNSIGNED-PAYLOAD';
    request.headers['x-oss-date'] = datetime;
    request.headers['Date'] = datetimeGmt;

    // Lowercase request headers
    final headers = <String, String>{};
    for (final entry in request.headers.entries) {
      headers[entry.key.toLowerCase()] = entry.value;
    }

    // Lowercase additional headers
    final additionalSignedHeaders = <String>[];
    context.additionalHeaderNames?.forEach((key) {
      final lowkey = key.toLowerCase();
      if (!(lowkey == 'content-md5' ||
              lowkey == 'content-type' ||
              lowkey.startsWith('x-oss-')) &&
          headers.containsKey(lowkey)) {
        additionalSignedHeaders.add(lowkey);
      }
    });

    // CanonicalRequest
    final canonicalRequest = calcCanonicalRequest(
      request,
      resourcePath(context.bucket, context.key),
      headers,
      additionalSignedHeaders,
    );

    // StringToSign
    context.stringToSign = calcStringToSign(datetime, scope, canonicalRequest);
    context.dateToSign = date;
    context.scopeToSign = scope;
    additionalSignedHeaders.sort();
    context.additionalHeadersToSign = additionalSignedHeaders.join(';');
  }

  /// Update authorization header
  void postAuthHeader(
    RequestMessage request,
    SigningContext context,
    String signature,
  ) {
    final credential =
        'OSS4-HMAC-SHA256 Credential=${context.credentials!.accessKeyId}/${context.scopeToSign}';
    final signedHeaders = context.additionalHeadersToSign.isEmpty != false
        ? ''
        : ',AdditionalHeaders=${context.additionalHeadersToSign}';
    request.headers['Authorization'] =
        '$credential$signedHeaders,Signature=$signature';
  }

  /// Complete header-based authentication process
  void authHeader(RequestMessage request, SigningContext signingContext) {
    // step 1
    preAuthHeader(request, signingContext);

    // step 2
    final signingKey = calcSigningKey(signingContext);

    // step 3
    final signature = calcSignature(signingKey, signingContext.stringToSign);

    // step 4
    postAuthHeader(request, signingContext, signature);
  }

  /// Complete query-based authentication process
  void authQuery(RequestMessage request, SigningContext signingContext) {
    // step 1
    preAuthQuery(request, signingContext);

    // step 2
    final signingKey = calcSigningKey(signingContext);

    // step 3
    final signature = calcSignature(signingKey, signingContext.stringToSign);

    // step 4
    postAuthQuery(request, signingContext, signature);
  }
}
