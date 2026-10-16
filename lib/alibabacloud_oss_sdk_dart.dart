/// Core library exports for the Alibaba Cloud OSS SDK for Dart.
///
/// Import this library to access the main OSS client, request and result
/// models, credentials providers, retry utilities, signers, and shared types.
library;

// Core
export 'src/client.dart';
export 'src/clients.dart';
export 'src/configuration.dart';
export 'src/defaults.dart';
export 'src/enums.dart';
export 'src/progress.dart';
export 'src/sdk_info.dart';
export 'src/agentic/bucket_space_helper.dart';

// Credentials
export 'src/credentials/anonymous_credentials_provider.dart';
export 'src/credentials/closure_credentials_provider.dart';
export 'src/credentials/credentials.dart';
export 'src/credentials/credentials_provider.dart';
export 'src/credentials/environment_credentials_provider.dart';
export 'src/credentials/refresh_credentials_provider.dart';
export 'src/credentials/static_credentials_provider.dart';

// Errors
export 'src/errors/client_errors.dart';
export 'src/errors/error.dart';
export 'src/errors/server_error.dart';

// Logging
export 'src/logging/logging.dart';

// Models
export 'src/models/models.dart';

// Paginator
export 'src/paginator/paginator.dart';

// Retry
export 'src/retry/retry.dart';

// Signer
export 'src/signer/nop_signer.dart';
export 'src/signer/remote_signer_v1.dart';
export 'src/signer/remote_signer_v4.dart';
export 'src/signer/signer.dart';
export 'src/signer/signer_sub_resource.dart';
export 'src/signer/signer_v1.dart';
export 'src/signer/signer_v4.dart';
export 'src/signer/signing_context.dart';

// Types
export 'src/types/attributes.dart';
export 'src/types/byte_stream.dart';
export 'src/types/client_options.dart';
export 'src/types/operation_input.dart';
export 'src/types/operation_options.dart';
export 'src/types/operation_output.dart';
export 'src/types/request_message.dart';
export 'src/types/response_message.dart';

// Utils
export 'src/utils/crc64.dart';
export 'src/utils/mime_utils.dart';
export 'src/utils/oss_utils.dart';
export 'src/utils/user_agent.dart';
export 'src/utils/xml_parser.dart';
