import '../client_extensions.dart';
import '../types/operation_input.dart';
import '../types/operation_options.dart';
import '../transform/serde_functions.dart';
import 'agentic_bucket_client.dart';
import 'models/model_agentic_bucket.dart';
import 'transform/serde_agentic_bucket.dart';

/// AgenticBucket management operations.
extension AgenticBucketClientBasic on AgenticBucketClient {
  /// Creates an AgenticBucket; bucket is the user-defined logical prefix.
  Future<CreateAgenticBucketResult> createAgenticBucket(
    CreateAgenticBucketRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'CreateAgenticBucket',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': ''},
    );
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializeCreateAgenticBucket,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = CreateAgenticBucketResult();
    await Serde.deserializeOutput(result, output);
    return result;
  }

  /// Deletes a disabled AgenticBucket that has satisfied the server-side cooldown period.
  Future<DeleteAgenticBucketResult> deleteAgenticBucket(
    DeleteAgenticBucketRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'DeleteAgenticBucket',
      method: 'DELETE',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': ''},
    );
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializeBodyless,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = DeleteAgenticBucketResult();
    await Serde.deserializeOutput(result, output);
    return result;
  }

  /// Gets AgenticBucket information.
  Future<GetAgenticBucketResult> getAgenticBucket(
    GetAgenticBucketRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'GetAgenticBucket',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': ''},
    );
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializeBodyless,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = GetAgenticBucketResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeAgenticBucket.deserializeGetAgenticBucket],
    );
    return result;
  }

  /// Lists AgenticBuckets in the region; does not require a bucket.
  Future<ListAgenticBucketsResult> listAgenticBuckets(
    ListAgenticBucketsRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'ListAgenticBuckets',
      method: 'GET',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': ''},
    );
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializeListAgenticBuckets,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = ListAgenticBucketsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeAgenticBucket.deserializeListAgenticBuckets],
    );
    return result;
  }

  /// Sets Enabled/Disabled status; disabling does not mean immediately deletable.
  Future<PutAgenticBucketStatusResult> putAgenticBucketStatus(
    PutAgenticBucketStatusRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'PutAgenticBucketStatus',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'agenticBucket': '', 'status': ''},
    );
    request.status.ensureRequired('request.status');
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeAgenticBucket.serializePutAgenticBucketStatus,
        Serde.addContentMd5,
      ],
    );
    final output = await invokeOperation(input, options);
    final result = PutAgenticBucketStatusResult();
    await Serde.deserializeOutput(result, output);
    return result;
  }
}
