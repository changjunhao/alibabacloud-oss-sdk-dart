import 'client.dart';
import 'models/model_service.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_service.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide service operations
extension ClientService on Client {
  /// Lists all buckets that belong to your account in all regions.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListBucketsResult> listBuckets(
    ListBucketsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(operationName: 'ListBuckets', method: 'GET');

    // Serialize the request
    await SerdeService.serializeListBuckets(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = ListBucketsResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeService.deserializeListBuckets,
    ]);

    return result;
  }
}
