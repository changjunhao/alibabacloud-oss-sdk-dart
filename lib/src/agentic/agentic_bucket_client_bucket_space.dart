import '../client_extensions.dart';
import '../types/operation_input.dart';
import '../types/operation_options.dart';
import '../transform/serde_functions.dart';
import 'agentic_bucket_client.dart';
import 'models/model_agentic_bucket.dart';
import 'transform/serde_agentic_bucket.dart';

/// List operations for BucketSpaces under an AgenticBucket.
extension AgenticBucketClientBucketSpace on AgenticBucketClient {
  /// Lists BucketSpaces under the specified parent AgenticBucket.
  Future<ListBucketSpacesResult> listBucketSpaces(
    ListBucketSpacesRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'ListBucketSpaces',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': '', 'bucketSpace': ''},
    );
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializeListBucketSpaces,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = ListBucketSpacesResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeAgenticBucket.deserializeListBucketSpaces],
    );
    return result;
  }
}
