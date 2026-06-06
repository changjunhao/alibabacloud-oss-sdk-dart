import 'client.dart';
import 'models/model_region.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_region.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide region operations
extension ClientRegion on Client {
  /// Queries the endpoints of all supported regions or the endpoints of a specific region.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DescribeRegionsResult> describeRegions(
    DescribeRegionsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'DescribeRegions',
      method: 'GET',
      parameters: {'regions': ''},
    );

    // Serialize the request
    await SerdeRegion.serializeDescribeRegions(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = DescribeRegionsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeRegion.deserializeDescribeRegions],
    );

    return result;
  }
}
