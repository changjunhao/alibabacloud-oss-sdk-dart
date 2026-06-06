import 'credentials/credentials_provider.dart';
import 'signer/signer.dart';
import 'logging/log_agent.dart';
import 'retry/retryer.dart';
import 'enums.dart';

/// Configuration class for Alibaba Cloud OSS SDK.
///
/// This class contains all the configuration options for the OSS client.
class Configuration {
  /// The domain names that other services can use to access OSS.
  String? endpoint;

  /// The credentials provider to use when signing requests.
  CredentialsProvider? credentialsProvider;

  /// The region in which the bucket is located.
  String? region;

  /// Max retry count, default value is 3
  int? retryMaxAttempts;

  /// Maximum connections per host
  int? maxConnectionsPerHost;

  /// Sets request timeout, default value is 15s
  Duration? timeoutIntervalForRequest;

  /// Sets single object's max time, default value is 24h
  Duration? timeoutIntervalForResource;

  /// Sets the user specific identifier appended to the User-Agent header.
  String? userAgent;

  /// Retry policy
  Retryer? retryer;

  /// Check data integrity of uploads via the crc64 by default.
  /// This feature takes effect for PutObject, AppendObject, UploadPart, Uploader.UploadFrom and Uploader.UploadFile
  bool? enableUploadCRC64Validation;

  /// Check data integrity of download via the crc64 by default.
  /// This feature only takes effect for Downloader.DownloadFile, GetObjectToFile
  bool? enableDownloadCRC64Validation;

  /// Disable Https protocol on request. Default value is false
  HttpProtocol? httpProtocol;

  /// Skip certificate check. Default value is false
  bool? enableTLSVerify;

  /// Enable redirection. Default value is false
  bool? enableFollowRedirect;

  /// Use the path style request mode, where the bucket name is placed in the path. Default value is false
  bool? usePathStyle;

  /// Request mode using cname. Default value is false
  bool? useCname;

  /// Authentication with OSS Signature Version, Defaults is "v4"
  SignerVersion? signerVersion;

  /// Custom signer
  Signer? signer;

  /// Dual-stack endpoints are provided in some regions.
  /// This allows an IPv4 client and an IPv6 client to access a bucket by using the same endpoint.
  /// Set this to `true` to use a dual-stack endpoint for the requests.
  bool? useDualStackEndpoint;

  /// You can use an internal endpoint to communicate between Alibaba Cloud services located within the same
  /// region over the internal network. You are not charged for the traffic generated over the internal network.
  /// Set this to `true` to use an internal endpoint for the requests.
  bool? useInternalEndpoint;

  /// OSS provides the transfer acceleration feature to accelerate date transfers of data
  /// uploads and downloads across countries and regions.
  /// Set this to `true` to use an accelerate endpoint for the requests.
  bool? useAccelerateEndpoint;

  /// Additional signable headers.
  List<String>? additionalHeaders;

  /// Proxy host.
  String? proxyHost;

  /// OSS log agent
  LogAgent? logger;

  /// Creates a new Configuration instance.
  Configuration({
    this.endpoint,
    this.credentialsProvider,
    this.region,
    this.retryMaxAttempts,
    this.maxConnectionsPerHost,
    this.timeoutIntervalForRequest,
    this.timeoutIntervalForResource,
    this.userAgent,
    this.retryer,
    this.enableUploadCRC64Validation,
    this.enableDownloadCRC64Validation,
    this.httpProtocol,
    this.enableTLSVerify,
    this.enableFollowRedirect,
    this.usePathStyle,
    this.useCname,
    this.signerVersion,
    this.signer,
    this.useDualStackEndpoint,
    this.useInternalEndpoint,
    this.useAccelerateEndpoint,
    this.additionalHeaders,
    this.proxyHost,
    this.logger,
  });

  /// Creates a default Configuration instance.
  factory Configuration.defaultConfig() {
    return Configuration();
  }

  /// Set the domain names that other services can use to access OSS.
  ///
  /// [endpoint] - The domain names that other services can use to access OSS.
  /// Returns this Configuration instance for method chaining.
  Configuration withEndpoint(String endpoint) {
    this.endpoint = endpoint;
    return this;
  }

  /// Set the credentials provider to use when signing requests.
  ///
  /// [credentialsProvider] - The credentials provider to use when signing requests.
  /// Returns this Configuration instance for method chaining.
  Configuration withCredentialsProvider(
    CredentialsProvider credentialsProvider,
  ) {
    this.credentialsProvider = credentialsProvider;
    return this;
  }

  /// Set the region in which the bucket is located.
  ///
  /// [region] - The region in which the bucket is located.
  /// Returns this Configuration instance for method chaining.
  Configuration withRegion(String region) {
    this.region = region;
    return this;
  }

  /// Set specifies the maximum number attempts an API client will call
  ///
  /// [retryMaxAttempts] - Specifies the maximum number attempts an API client will call
  /// Returns this Configuration instance for method chaining.
  Configuration withRetryMaxAttempts(int retryMaxAttempts) {
    this.retryMaxAttempts = retryMaxAttempts;
    return this;
  }

  /// Set maximum connections per host
  ///
  /// [maxConnectionsPerHost] - Maximum connections per host
  /// Returns this Configuration instance for method chaining.
  Configuration withMaxConnectionsPerHost(int maxConnectionsPerHost) {
    this.maxConnectionsPerHost = maxConnectionsPerHost;
    return this;
  }

  /// Set request timeout period
  ///
  /// [timeoutIntervalForRequest] - Request timeout period
  /// Returns this Configuration instance for method chaining.
  Configuration withTimeoutIntervalForRequest(
    Duration timeoutIntervalForRequest,
  ) {
    this.timeoutIntervalForRequest = timeoutIntervalForRequest;
    return this;
  }

  /// Sets single object's max time.
  ///
  /// [timeoutIntervalForResource] - Single object's max time
  /// Returns this Configuration instance for method chaining.
  Configuration withTimeoutIntervalForResource(
    Duration timeoutIntervalForResource,
  ) {
    this.timeoutIntervalForResource = timeoutIntervalForResource;
    return this;
  }

  /// Set the optional user specific identifier appended to the User-Agent header.
  ///
  /// [userAgent] - The optional user specific identifier appended to the User-Agent header.
  /// Returns this Configuration instance for method chaining.
  Configuration withUserAgent(String userAgent) {
    this.userAgent = userAgent;
    return this;
  }

  /// Set guides how HTTP requests should be retried in case of recoverable failures.
  ///
  /// [retryer] - Guides how HTTP requests should be retried in case of recoverable failures.
  /// Returns this Configuration instance for method chaining.
  Configuration withRetryer(Retryer retryer) {
    this.retryer = retryer;
    return this;
  }

  /// Check data integrity of uploads via the crc64 by default.
  ///
  /// [enableUploadCRC64Validation] - Enable upload CRC64 validation
  /// Returns this Configuration instance for method chaining.
  Configuration withUploadCRC64Validation(bool enableUploadCRC64Validation) {
    this.enableUploadCRC64Validation = enableUploadCRC64Validation;
    return this;
  }

  /// Check data integrity of download via the crc64 by default.
  ///
  /// [enableDownloadCRC64Validation] - Enable download CRC64 validation
  /// Returns this Configuration instance for method chaining.
  Configuration withDownloadCRC64Validation(
    bool enableDownloadCRC64Validation,
  ) {
    this.enableDownloadCRC64Validation = enableDownloadCRC64Validation;
    return this;
  }

  /// Set up HTTP protocol
  ///
  /// [httpProtocol] - HTTP or HTTPS
  /// Returns this Configuration instance for method chaining.
  Configuration withHttpProtocol(HttpProtocol httpProtocol) {
    this.httpProtocol = httpProtocol;
    return this;
  }

  /// Skip certificate check.
  ///
  /// [enableTLSVerify] - Enable TLS verification
  /// Returns this Configuration instance for method chaining.
  Configuration withTLSVerify(bool enableTLSVerify) {
    this.enableTLSVerify = enableTLSVerify;
    return this;
  }

  /// Set enable http redirect or not. Default is disable
  ///
  /// [enableFollowRedirect] - Enable http redirect or not. Default is disable
  /// Returns this Configuration instance for method chaining.
  Configuration withFollowRedirect(bool enableFollowRedirect) {
    this.enableFollowRedirect = enableFollowRedirect;
    return this;
  }

  /// Set allows you to enable the client to use path-style addressing,
  ///
  /// [usePathStyle] - Use path style addressing
  /// Returns this Configuration instance for method chaining.
  Configuration withUsePathStyle(bool usePathStyle) {
    this.usePathStyle = usePathStyle;
    return this;
  }

  /// Set if the endpoint is a CName, set this flag to true
  ///
  /// [useCname] - Use CName
  /// Returns this Configuration instance for method chaining.
  Configuration withUseCname(bool useCname) {
    this.useCname = useCname;
    return this;
  }

  /// Set dual-stack endpoints are provided in some regions.
  ///
  /// [useDualStackEndpoint] - Dual-stack endpoints are provided in some regions.
  /// Returns this Configuration instance for method chaining.
  Configuration withUseDualStackEndpoint(bool useDualStackEndpoint) {
    this.useDualStackEndpoint = useDualStackEndpoint;
    return this;
  }

  /// You can use an internal endpoint to communicate between Alibaba Cloud services located
  ///
  /// [useInternalEndpoint] - Use internal endpoint
  /// Returns this Configuration instance for method chaining.
  Configuration withUseInternalEndpoint(bool useInternalEndpoint) {
    this.useInternalEndpoint = useInternalEndpoint;
    return this;
  }

  /// Set OSS provides the transfer acceleration feature to accelerate date transfers
  ///
  /// [useAccelerateEndpoint] - OSS provides the transfer acceleration feature to accelerate date transfers
  /// Returns this Configuration instance for method chaining.
  Configuration withUseAccelerateEndpoint(bool useAccelerateEndpoint) {
    this.useAccelerateEndpoint = useAccelerateEndpoint;
    return this;
  }

  /// Set the signature version when signing requests. Valid values v4, v1
  ///
  /// [signerVersion] - Signer version
  /// Returns this Configuration instance for method chaining.
  Configuration withSignerVersion(SignerVersion signerVersion) {
    this.signerVersion = signerVersion;
    return this;
  }

  /// Set custom signer
  ///
  /// [signer] - The custom signer
  /// Returns this Configuration instance for method chaining.
  Configuration withSigner(Signer signer) {
    this.signer = signer;
    return this;
  }

  /// Set additional signable headers.
  ///
  /// [additionalHeaders] - Additional signable headers
  /// Returns this Configuration instance for method chaining.
  Configuration withAdditionalHeaders(List<String> additionalHeaders) {
    this.additionalHeaders = additionalHeaders;
    return this;
  }

  /// Set proxy host.
  ///
  /// [proxyHost] - Proxy host
  /// Returns this Configuration instance for method chaining.
  Configuration withProxyHost(String proxyHost) {
    this.proxyHost = proxyHost;
    return this;
  }

  /// Set up logger
  ///
  /// [logger] - Logger
  /// Returns this Configuration instance for method chaining.
  Configuration withLogger(LogAgent logger) {
    this.logger = logger;
    return this;
  }

  /// Creates a copy of this Configuration with optionally updated values
  Configuration copyWith({
    String? endpoint,
    CredentialsProvider? credentialsProvider,
    String? region,
    int? retryMaxAttempts,
    int? maxConnectionsPerHost,
    Duration? timeoutIntervalForRequest,
    Duration? timeoutIntervalForResource,
    String? userAgent,
    Retryer? retryer,
    bool? enableUploadCRC64Validation,
    bool? enableDownloadCRC64Validation,
    HttpProtocol? httpProtocol,
    bool? enableTLSVerify,
    bool? enableFollowRedirect,
    bool? usePathStyle,
    bool? useCname,
    SignerVersion? signerVersion,
    Signer? signer,
    bool? useDualStackEndpoint,
    bool? useInternalEndpoint,
    bool? useAccelerateEndpoint,
    List<String>? additionalHeaders,
    String? proxyHost,
    LogAgent? logger,
  }) {
    return Configuration(
      endpoint: endpoint ?? this.endpoint,
      credentialsProvider: credentialsProvider ?? this.credentialsProvider,
      region: region ?? this.region,
      retryMaxAttempts: retryMaxAttempts ?? this.retryMaxAttempts,
      maxConnectionsPerHost:
          maxConnectionsPerHost ?? this.maxConnectionsPerHost,
      timeoutIntervalForRequest:
          timeoutIntervalForRequest ?? this.timeoutIntervalForRequest,
      timeoutIntervalForResource:
          timeoutIntervalForResource ?? this.timeoutIntervalForResource,
      userAgent: userAgent ?? this.userAgent,
      retryer: retryer ?? this.retryer,
      enableUploadCRC64Validation:
          enableUploadCRC64Validation ?? this.enableUploadCRC64Validation,
      enableDownloadCRC64Validation:
          enableDownloadCRC64Validation ?? this.enableDownloadCRC64Validation,
      httpProtocol: httpProtocol ?? this.httpProtocol,
      enableTLSVerify: enableTLSVerify ?? this.enableTLSVerify,
      enableFollowRedirect: enableFollowRedirect ?? this.enableFollowRedirect,
      usePathStyle: usePathStyle ?? this.usePathStyle,
      useCname: useCname ?? this.useCname,
      signerVersion: signerVersion ?? this.signerVersion,
      signer: signer ?? this.signer,
      useDualStackEndpoint: useDualStackEndpoint ?? this.useDualStackEndpoint,
      useInternalEndpoint: useInternalEndpoint ?? this.useInternalEndpoint,
      useAccelerateEndpoint:
          useAccelerateEndpoint ?? this.useAccelerateEndpoint,
      additionalHeaders:
          additionalHeaders ??
          (this.additionalHeaders != null
              ? List<String>.from(this.additionalHeaders!)
              : null),
      proxyHost: proxyHost ?? this.proxyHost,
      logger: logger ?? this.logger,
    );
  }

  @override
  String toString() {
    return 'Configuration('
        'endpoint: $endpoint, '
        'credentialsProvider: $credentialsProvider, '
        'region: $region, '
        'retryMaxAttempts: $retryMaxAttempts, '
        'maxConnectionsPerHost: $maxConnectionsPerHost, '
        'timeoutIntervalForRequest: $timeoutIntervalForRequest, '
        'timeoutIntervalForResource: $timeoutIntervalForResource, '
        'userAgent: $userAgent, '
        'retryer: $retryer, '
        'enableUploadCRC64Validation: $enableUploadCRC64Validation, '
        'enableDownloadCRC64Validation: $enableDownloadCRC64Validation, '
        'httpProtocol: $httpProtocol, '
        'enableTLSVerify: $enableTLSVerify, '
        'enableFollowRedirect: $enableFollowRedirect, '
        'usePathStyle: $usePathStyle, '
        'useCname: $useCname, '
        'signerVersion: $signerVersion, '
        'signer: $signer, '
        'useDualStackEndpoint: $useDualStackEndpoint, '
        'useInternalEndpoint: $useInternalEndpoint, '
        'useAccelerateEndpoint: $useAccelerateEndpoint, '
        'additionalHeaders: $additionalHeaders, '
        'proxyHost: $proxyHost, '
        'logger: $logger)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Configuration &&
        other.endpoint == endpoint &&
        other.credentialsProvider == credentialsProvider &&
        other.region == region &&
        other.retryMaxAttempts == retryMaxAttempts &&
        other.maxConnectionsPerHost == maxConnectionsPerHost &&
        other.timeoutIntervalForRequest == timeoutIntervalForRequest &&
        other.timeoutIntervalForResource == timeoutIntervalForResource &&
        other.userAgent == userAgent &&
        other.retryer == retryer &&
        other.enableUploadCRC64Validation == enableUploadCRC64Validation &&
        other.enableDownloadCRC64Validation == enableDownloadCRC64Validation &&
        other.httpProtocol == httpProtocol &&
        other.enableTLSVerify == enableTLSVerify &&
        other.enableFollowRedirect == enableFollowRedirect &&
        other.usePathStyle == usePathStyle &&
        other.useCname == useCname &&
        other.signerVersion == signerVersion &&
        other.signer == signer &&
        other.useDualStackEndpoint == useDualStackEndpoint &&
        other.useInternalEndpoint == useInternalEndpoint &&
        other.useAccelerateEndpoint == useAccelerateEndpoint &&
        _listEquals(other.additionalHeaders, additionalHeaders) &&
        other.proxyHost == proxyHost &&
        other.logger == logger;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      endpoint,
      credentialsProvider,
      region,
      retryMaxAttempts,
      maxConnectionsPerHost,
      timeoutIntervalForRequest,
      timeoutIntervalForResource,
      userAgent,
      retryer,
      enableUploadCRC64Validation,
      enableDownloadCRC64Validation,
      httpProtocol,
      enableTLSVerify,
      enableFollowRedirect,
      usePathStyle,
      useCname,
      signerVersion,
      signer,
      useDualStackEndpoint,
      useInternalEndpoint,
      useAccelerateEndpoint,
      additionalHeaders,
      proxyHost,
      logger,
    ]);
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
