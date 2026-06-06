import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_policy.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket policy operations serialization and deserialization
extension SerdeBucketPolicy on Serde {
  // MARK: - PutBucketPolicy

  /// Serialize PutBucketPolicy request
  static Future<void> serializePutBucketPolicy(
    PutBucketPolicyRequest request,
    OperationInput input,
  ) async {
    if (request.body != null) {
      final data = Uint8List.fromList(utf8.encode(request.body!));
      input.body = ByteStream.fromData(data);
    }
  }

  /// Deserialize PutBucketPolicy result
  static Future<void> deserializePutBucketPolicy(
    PutBucketPolicyResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketPolicy
  }

  // MARK: - GetBucketPolicy

  /// Serialize GetBucketPolicy request
  static Future<void> serializeGetBucketPolicy(
    GetBucketPolicyRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketPolicy
  }

  /// Deserialize GetBucketPolicy result
  static Future<void> deserializeGetBucketPolicy(
    GetBucketPolicyResult result,
    OperationOutput output,
  ) async {
    if (output.body != null) {
      final data = await output.body!.readData();
      if (data != null) {
        result.body = utf8.decode(data);
      }
    }
  }

  // MARK: - DeleteBucketPolicy

  /// Serialize DeleteBucketPolicy request
  static Future<void> serializeDeleteBucketPolicy(
    DeleteBucketPolicyRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketPolicy
  }

  /// Deserialize DeleteBucketPolicy result
  static Future<void> deserializeDeleteBucketPolicy(
    DeleteBucketPolicyResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketPolicy
  }

  // MARK: - GetBucketPolicyStatus

  /// Serialize GetBucketPolicyStatus request
  static Future<void> serializeGetBucketPolicyStatus(
    GetBucketPolicyStatusRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketPolicyStatus
  }

  /// Deserialize GetBucketPolicyStatus result
  static Future<void> deserializeGetBucketPolicyStatus(
    GetBucketPolicyStatusResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'PolicyStatus',
    );
    result.policyStatus = PolicyStatus.fromJson(body);
  }
}
