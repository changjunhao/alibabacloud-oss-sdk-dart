import 'dart:async';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../configuration.dart';
import '../types/client_options.dart';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/operation_options.dart';
import '../types/request_message.dart';
import '../types/attributes.dart';
import '../credentials/anonymous_credentials_provider.dart';
import '../signer/signer.dart';
import '../signer/signer_v1.dart';
import '../signer/signer_v4.dart';
import '../signer/signing_context.dart';
import '../retry/retryer.dart';
import '../retry/standard_retryer.dart';
import '../logging/log_agent.dart';
import '../utils/user_agent.dart';
import '../utils/oss_utils.dart';
import '../errors/client_errors.dart';
import '../enums.dart';
import '../defaults.dart';
import '../progress.dart';
import 'execute_stack.dart';
import 'execute_context.dart';

import 'response_handler.dart';
import 'oss_http_client_delegate.dart';
import 'retryer_middleware.dart';
import 'signer_middleware.dart';
import 'response_checker_middleware.dart';

/// Inner options for client implementation
class InnerOptions {
  /// The `userAgent` value.
  final String userAgent;

  /// The `logger` value.
  final LogAgent? logger;

  /// The `dio` value.
  final Dio dio;

  /// The `dioOwner` value.
  final bool dioOwner;

  /// Initialization error deferred to the first operation or presign call.
  final ClientError? initError;

  /// Creates an InnerOptions instance.
  const InnerOptions({
    required this.userAgent,
    this.logger,
    required this.dio,
    required this.dioOwner,
    this.initError,
  });
}

/// Presign inner result containing presigned URL information
class PresignInnerResult {
  /// The `method` value.
  String? method;

  /// The `url` value.
  String? url;

  /// The `expiration` value.
  DateTime? expiration;

  /// The `signedHeaders` value.
  Map<String, String>? signedHeaders;

  /// Creates a PresignInnerResult instance.
  PresignInnerResult({
    this.method,
    this.url,
    this.expiration,
    this.signedHeaders,
  });
}

/// Client implementation class for OSS operations
class ClientImpl {
  /// The `executeStack` value.
  late final ExecuteStack executeStack;

  /// The `options` value.
  final ClientOptions options;

  /// The `innerOptions` value.
  final InnerOptions innerOptions;

  /// Creates a new ClientImpl instance
  ClientImpl(
    Configuration config, [
    List<ClientOptionsAction> actions = const [],
  ]) : options = _resolveConfig(config),
       innerOptions = _resolveInnerOptions(config) {
    // Apply actions to options
    for (final action in actions) {
      action(options);
    }

    // Build execute stack
    final stack = options.executeMW != null
        ? ExecuteStack.withHandler(options.executeMW!)
        : ExecuteStack.withDio(
            dio: innerOptions.dio,
            logger: innerOptions.logger,
          );

    // Add retry middleware
    stack.push(
      (next) => RetryerMiddleware(
        nextHandler: next,
        retryer: options.retryer,
        logger: innerOptions.logger,
        retryHandler:
            options.featureFlags.contains(FeatureFlag.correctClockSkew)
            ? FixTimeRetryHandler()
            : null,
      ),
      'Retryer',
    );

    // Add signer middleware
    stack.push(
      (next) => SignerMiddleware(
        nextHandler: next,
        signer: options.signer,
        provider: options.credentialsProvider,
        logger: innerOptions.logger,
      ),
      'Signer',
    );

    // Add response checker middleware
    stack.push(
      (next) => ResponseCheckerMiddleware(
        nextHandler: next,
        logger: innerOptions.logger,
      ),
      'Checker',
    );

    executeStack = stack;
  }

  /// Checks if a feature flag is enabled
  bool hasFeatureFlag(FeatureFlag flag) {
    return options.featureFlags.contains(flag);
  }

  /// Disposes resources
  void dispose() {
    if (innerOptions.dioOwner) {
      innerOptions.dio.close();
    }
  }

  /// Resolves configuration to client options
  static ClientOptions _resolveConfig(Configuration config) {
    final product = Defaults.product;
    final region = config.region ?? '';
    final endpoint = _resolveEndpoint(config);
    final retryer = _resolveRetryer(config);
    final signer = _resolveSigner(config);
    final addressStyle = _resolveAddressStyle(config, endpoint);
    final featureFlags = _resolveFeatureFlags(config);

    final opts = ClientOptions(
      product: product,
      region: region,
      endpoint: endpoint,
      retryMaxAttempts: config.retryMaxAttempts ?? Defaults.maxAttempt,
      retryer: retryer,
      signer: signer,
      credentialsProvider: config.credentialsProvider,
      addressStyle: addressStyle,
      featureFlags: featureFlags,
    );

    opts.additionalHeaders = config.additionalHeaders ?? opts.additionalHeaders;
    return opts;
  }

  /// Resolves endpoint from configuration
  static Uri? _resolveEndpoint(Configuration config) {
    String endpoint;

    if (config.endpoint != null && config.endpoint!.isNotEmpty) {
      endpoint = config.endpoint!;
    } else {
      final region = config.region;
      if (region == null) {
        return null;
      }

      EndpointType endpointType;
      if (config.useDualStackEndpoint == true) {
        endpointType = EndpointType.dualstack;
      } else if (config.useInternalEndpoint == true) {
        endpointType = EndpointType.internal;
      } else if (config.useAccelerateEndpoint == true) {
        endpointType = EndpointType.accelerate;
      } else {
        endpointType = EndpointType.defautt;
      }

      endpoint = OSSUtils.regionToEndpoint(region, endpointType);
    }

    if (!endpoint.contains('://')) {
      final protocol = config.httpProtocol?.value ?? Defaults.httpProtocol;
      endpoint = '$protocol://$endpoint';
    }

    return Uri.tryParse(endpoint);
  }

  /// Resolves retryer from configuration
  static Retryer _resolveRetryer(Configuration config) {
    return config.retryer ??
        StandardRetryer(maxAttempt: config.retryMaxAttempts);
  }

  /// Resolves signer from configuration
  static Signer _resolveSigner(Configuration config) {
    if (config.signer != null) {
      return config.signer!;
    }

    switch (config.signerVersion) {
      case SignerVersion.v1:
        return SignerV1();
      default:
        return SignerV4();
    }
  }

  /// Resolves inner options from configuration
  static InnerOptions _resolveInnerOptions(Configuration config) {
    final userAgent = _resolveUserAgent(config);
    final (dio, dioOwner) = _resolveDio(config);

    return InnerOptions(
      userAgent: userAgent,
      logger: config.logger,
      dio: dio,
      dioOwner: dioOwner,
      initError: _resolveInitError(config),
    );
  }

  static ClientError? _resolveInitError(Configuration config) {
    final accountId = config.accountId;
    if (accountId != null &&
        accountId.codeUnits.any((unit) => unit < 0x30 || unit > 0x39)) {
      return ValidationErrors.accountIdInvalidError(accountId);
    }
    return null;
  }

  /// Resolves Dio instance from configuration
  static (Dio, bool) _resolveDio(Configuration config) {
    const owner = true;

    // Create HTTP client delegate with configuration
    final delegate = OSSHttpClientDelegate(
      enableTLSVerify: config.enableTLSVerify ?? true,
      enableFollowRedirect: config.enableFollowRedirect ?? false,
    );

    // Create and configure Dio instance using the delegate
    final dio = delegate.createConfiguredDio();

    // Configure timeouts
    dio.options.connectTimeout =
        config.timeoutIntervalForRequest ?? Defaults.timeoutIntervalForRequest;
    dio.options.receiveTimeout =
        config.timeoutIntervalForResource ??
        Defaults.timeoutIntervalForResource;
    dio.options.sendTimeout =
        config.timeoutIntervalForResource ??
        Defaults.timeoutIntervalForResource;

    // Configure cache policy
    dio.options.extra['cachePolicy'] = 'no-cache';

    // Configure proxy if specified
    if (config.proxyHost != null) {
      var proxyHost = config.proxyHost!;
      if (!proxyHost.contains('://')) {
        proxyHost = 'http://$proxyHost';
      }

      final proxyUri = Uri.tryParse(proxyHost);
      if (proxyUri != null) {
        dio.options.extra['proxy'] = proxyHost;
      }
    }

    // Configure max connections
    if (config.maxConnectionsPerHost != null) {
      dio.options.extra['maxConnectionsPerHost'] = config.maxConnectionsPerHost;
    }

    // Add redirect interceptor if needed
    dio.interceptors.add(delegate.createRedirectInterceptor());

    return (dio, owner);
  }

  /// Resolves address style from configuration
  static AddressStyleType _resolveAddressStyle(
    Configuration config,
    Uri? endpoint,
  ) {
    AddressStyleType style;

    if (config.useCname == true) {
      style = AddressStyleType.cname;
    } else if (config.usePathStyle == true) {
      style = AddressStyleType.path;
    } else if (config.useVirtualHostedAlias == true) {
      style = AddressStyleType.virtualHostedAlias;
    } else {
      style = AddressStyleType.virtualHosted;
    }

    if (endpoint != null && endpoint.host.isNotEmpty) {
      // Check if host is IP address (IPv4 or IPv6)
      final isIpv4 = RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(endpoint.host);
      final isIpv6 = RegExp(r'^\[?[0-9a-fA-F:]+\]?$').hasMatch(endpoint.host);
      if (isIpv4 || isIpv6) {
        style = AddressStyleType.path;
      }
    }

    return style;
  }

  /// Resolves user agent from configuration
  static String _resolveUserAgent(Configuration config) {
    var ua = UserAgent.getDefault();
    if (config.userAgent != null) {
      ua = '$ua /${config.userAgent}';
    }
    return ua;
  }

  /// Resolves feature flags from configuration
  static FeatureFlag _resolveFeatureFlags(Configuration config) {
    var featureFlags = Defaults.featureFlags;

    if (config.enableUploadCRC64Validation != null) {
      if (config.enableUploadCRC64Validation!) {
        featureFlags = featureFlags | FeatureFlag.enableCRC64CheckUpload;
      } else {
        // Remove flag by creating new FeatureFlag without this flag
        final newRawValue =
            featureFlags.rawValue &
            ~FeatureFlag.enableCRC64CheckUpload.rawValue;
        featureFlags = FeatureFlag.fromRawValue(newRawValue);
      }
    }

    if (config.enableDownloadCRC64Validation != null) {
      if (config.enableDownloadCRC64Validation!) {
        featureFlags = featureFlags | FeatureFlag.enableCRC64CheckDownload;
      } else {
        // Remove flag by creating new FeatureFlag without this flag
        final newRawValue =
            featureFlags.rawValue &
            ~FeatureFlag.enableCRC64CheckDownload.rawValue;
        featureFlags = FeatureFlag.fromRawValue(newRawValue);
      }
    }

    return featureFlags;
  }

  /// Verifies operation input parameters
  @visibleForTesting
  static Future<void> verifyOperation(OperationInput input) async {
    if (input.bucket != null && !input.bucket!.isValidBucketName()) {
      throw ValidationErrors.bucketInvalidError(input.bucket!);
    }

    if (input.key != null && !input.key!.isValidObjectKey()) {
      throw ValidationErrors.objectInvalidError(input.key!);
    }
  }

  Future<void> _preflight(OperationInput input) async {
    final error = innerOptions.initError;
    if (error != null) throw error;
    if (options.endpoint == null) {
      throw ValidationErrors.endpointInvalidError();
    }
    await verifyOperation(input);
  }

  /// Executes an operation with the given input
  Future<OperationOutput> execute(
    OperationInput input, {
    OperationOptions? operationOptions,
  }) async {
    // Verify input
    await _preflight(input);

    // Build request context
    final (request, context) = await _buildRequestContext(
      input,
      operationOptions,
    );

    try {
      // Execute and wait for result
      final result = await executeStack.execute(request, context);

      return OperationOutput(
        input: input,
        statusCode: result.statusCode,
        headers: result.headers,
        body: result.content,
      );
    } catch (error) {
      // Re-throw as operation error
      rethrow;
    }
  }

  /// Presigns a request and returns presign information
  Future<PresignInnerResult> presignInner(
    OperationInput input, {
    OperationOptions? operationOptions,
  }) async {
    // Verify input
    await _preflight(input);

    // Build request context
    final (request, context) = await _buildRequestContext(
      input,
      operationOptions,
    );

    var result = PresignInnerResult(
      method: request.method,
      url: request.requestUri.toString(),
    );

    final provider = options.credentialsProvider;
    if (provider == null || provider is AnonymousCredentialsProvider) {
      return result;
    }

    final credentials = await provider.getCredentials();
    if (credentials.isEmpty()) {
      throw CredentialsErrors.credentialsEmptyError();
    }

    context.signingContext?.credentials = credentials;
    context.signingContext?.authHeader = false;

    final signedRequest = await options.signer.sign(
      request,
      context.signingContext!,
    );

    // Update signable headers & check max expiration time
    final expiration = context.signingContext!.expirationTime!;
    final expect = ['content-type', 'content-md5'];

    if (options.signer is SignerV4) {
      context.signingContext?.additionalHeaderNames?.forEach((header) {
        expect.add(header.toLowerCase());
      });

      final expires = expiration.difference(DateTime.now()).inSeconds;
      if (expires > 7 * 24 * 3600) {
        throw PresignErrors.presignExpirationError(expiration);
      }
    }

    final signedHeaders = <String, String>{};
    for (final entry in signedRequest.headers.entries) {
      final lowKey = entry.key.toLowerCase();
      if (expect.contains(lowKey) || lowKey.startsWith('x-oss-')) {
        signedHeaders[lowKey] = entry.value;
      }
    }

    result.url = signedRequest.requestUri.toString();
    result.expiration = expiration;
    result.signedHeaders = signedHeaders;

    return result;
  }

  /// Builds request context from operation input
  Future<(RequestMessage, ExecuteContext)> _buildRequestContext(
    OperationInput input,
    OperationOptions? operationOptions,
  ) async {
    // Default API options
    final retryMaxAttempts = operationOptions?.retryMaxAttempts;
    final readWriteTimeout = operationOptions?.readWriteTimeout;

    final responseHandlers = <ResponseHandler>[ServerResponseHandler()];

    // Response delegate
    final handlers = input.metadata.values(AttributeKeys.responseHandlers);
    if (handlers != null) {
      responseHandlers.addAll(handlers.cast<ResponseHandler>());
    }

    // Signing context
    final resolver = options.bucketNameResolver;
    final signingBucket = input.bucket != null && resolver != null
        ? resolver(input)
        : input.bucket;
    var signingContext = SigningContext(
      bucket: signingBucket,
      key: input.key,
      region: options.region,
      product: options.product,
      additionalHeaderNames: options.additionalHeaders,
    );

    // Signing time from user
    final expirationTime = input.metadata.get<DateTime>(
      AttributeKeys.expirationTime,
    );
    if (expirationTime != null) {
      signingContext.expirationTime = expirationTime;
    }

    // Request
    final endpoint = options.endpoint;
    if (endpoint == null) {
      throw ValidationErrors.endpointInvalidError();
    }

    final provider = options.endpointProvider;
    var url = provider != null
        ? provider(input)
        : '${endpoint.scheme}://${_buildHostPath(input, host: _hostPort(endpoint), addressStyle: options.addressStyle)}';
    final query = _queryString(input);
    if (query.isNotEmpty) {
      url = '$url?$query';
    }

    final uri = Uri.parse(url);

    // Request headers
    final headers = <String, String>{};
    for (final entry in input.headers.entries) {
      headers[entry.key.toLowerCase()] = entry.value;
    }
    headers['user-agent'] = innerOptions.userAgent;

    // Request
    final request = RequestMessage(
      method: input.method,
      requestUri: uri,
      headers: headers,
      content: input.body,
    );

    // Progress delegate from metadata
    final progressDelegate = input.metadata.get<ProgressDelegateDesc>(
      ProgressAttributeKeys.progressDelegate,
    );

    final context = ExecuteContext(
      retryMaxAttempts: retryMaxAttempts,
      readWriteTimeout: readWriteTimeout?.inMilliseconds,
      signingContext: signingContext,
      progressDelegate: progressDelegate,
      responseHandlers: responseHandlers,
      saveToURL: operationOptions?.saveToURL,
      cancelToken: operationOptions?.cancelToken,
    );

    return (request, context);
  }

  /// Builds host and path for the request
  String _buildHostPath(
    OperationInput input, {
    required String host,
    required AddressStyleType addressStyle,
  }) {
    final paths = <String>[];
    var baseUrl = host;

    if (input.bucket != null) {
      switch (addressStyle) {
        case AddressStyleType.path:
          paths.add(input.bucket!);
          if (input.key == null) {
            paths.add('');
          }
          break;
        case AddressStyleType.cname:
          break;
        default: // virtual host
          baseUrl = '${input.bucket!}.$host';
      }
    }

    if (input.key != null) {
      final encodedKey = Uri.encodeComponent(input.key!).replaceAll('%2F', '/');
      paths.add(encodedKey);
    }

    return '$baseUrl/${paths.join('/')}';
  }

  /// Builds query string from operation input parameters
  String _queryString(OperationInput input) {
    if (input.parameters.isEmpty) {
      return '';
    }

    return input.parameters.entries
        .map((entry) {
          final name = entry.key.urlEncode() ?? entry.key;
          final value = entry.value != null
              ? (entry.value!.urlEncode() ?? entry.value!)
              : '';
          return '$name=$value';
        })
        .join('&');
  }

  /// Gets host and port from URI
  String _hostPort(Uri uri) {
    var str = uri.host;
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      str += ':${uri.port}';
    }
    return str;
  }
}

/// Extension methods for OperationInput
extension OperationInputExtensions on OperationInput {
  /// Builds path based on address style
  String? buildPath(AddressStyleType pathStyle) {
    String? path;

    if (bucket != null) {
      if (pathStyle == AddressStyleType.path) {
        path = '/$bucket';
      }
    }

    if (key != null) {
      final encodedKey = Uri.encodeComponent(key!).replaceAll('%2F', '/');
      path = '${path ?? ''}/$encodedKey';
    }

    return path;
  }

  /// Builds host based on endpoint and path style
  String buildHost(String endpoint, AddressStyleType pathStyle) {
    final uri = Uri.parse(endpoint);
    var host = uri.host;

    if (bucket != null && pathStyle != AddressStyleType.cname) {
      host = '$bucket.$host';
    }

    return host;
  }

  /// Builds query items from parameters
  List<MapEntry<String, String?>> queryItems() {
    return parameters.entries.map((entry) {
      final name = Uri.encodeQueryComponent(entry.key);
      final value = entry.value != null
          ? Uri.encodeQueryComponent(entry.value!)
          : null;
      return MapEntry(name, value);
    }).toList();
  }

  /// Builds query string from parameters
  String queryString() {
    if (parameters.isEmpty) {
      return '';
    }

    return parameters.entries
        .map((entry) {
          final name = Uri.encodeQueryComponent(entry.key);
          final value = entry.value != null
              ? Uri.encodeQueryComponent(entry.value!)
              : '';
          return '$name=$value';
        })
        .join('&');
  }

  /// Builds host and path for the request
  String buildHostPath(String host, AddressStyleType addressStyle) {
    final paths = <String>[];
    var baseUrl = host;

    if (bucket != null) {
      switch (addressStyle) {
        case AddressStyleType.path:
          paths.add(bucket!);
          if (key == null) {
            paths.add('');
          }
          break;
        case AddressStyleType.cname:
          break;
        default: // virtual host
          baseUrl = '$bucket.$host';
      }
    }

    if (key != null) {
      final encodedKey = Uri.encodeComponent(key!).replaceAll('%2F', '/');
      paths.add(encodedKey);
    }

    return '$baseUrl/${paths.join('/')}';
  }
}

/// Extension methods for Uri
extension UriExtensions on Uri {
  /// Gets host and port as string
  String hostPort() {
    var str = host;
    if (hasPort && port != 80 && port != 443) {
      str += ':$port';
    }
    return str;
  }
}
