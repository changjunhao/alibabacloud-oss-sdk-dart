import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_request_payment.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket request payment operations serialization and deserialization
extension SerdeBucketRequestPayment on Serde {
  // MARK: - PutBucketRequestPayment

  /// Serialize PutBucketRequestPayment request
  static Future<void> serializePutBucketRequestPayment(
    PutBucketRequestPaymentRequest request,
    OperationInput input,
  ) async {
    if (request.requestPaymentConfiguration != null) {
      final xmlData = _requestPaymentConfigurationToXml(
        request.requestPaymentConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketRequestPayment result
  static Future<void> deserializePutBucketRequestPayment(
    PutBucketRequestPaymentResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketRequestPayment
  }

  // MARK: - GetBucketRequestPayment

  /// Serialize GetBucketRequestPayment request
  static Future<void> serializeGetBucketRequestPayment(
    GetBucketRequestPaymentRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketRequestPayment
  }

  /// Deserialize GetBucketRequestPayment result
  static Future<void> deserializeGetBucketRequestPayment(
    GetBucketRequestPaymentResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'RequestPaymentConfiguration',
    );
    result.requestPaymentConfiguration = RequestPaymentConfiguration.fromJson(
      body,
    );
  }

  // MARK: - Helper Methods

  /// Convert RequestPaymentConfiguration to XML data
  static Uint8List _requestPaymentConfigurationToXml(
    RequestPaymentConfiguration config,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<RequestPaymentConfiguration>';

    if (config.payer != null) {
      xmlBody += '<Payer>${config.payer}</Payer>';
    }

    xmlBody += '</RequestPaymentConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
