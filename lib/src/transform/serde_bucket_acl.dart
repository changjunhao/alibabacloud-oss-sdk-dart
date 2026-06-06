import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../models/model_bucket_acl.dart';
import '../models/model_shared.dart';
import 'serde_functions.dart';

/// Extension for bucket ACL operations serialization and deserialization
extension SerdeBucketAcl on Serde {
  // MARK: - PutBucketAcl

  /// Serialize PutBucketAcl request
  static Future<void> serializePutBucketAcl(
    PutBucketAclRequest request,
    OperationInput input,
  ) async {
    if (request.acl != null) {
      input.headers['x-oss-acl'] = request.acl!;
    }
  }

  /// Deserialize PutBucketAcl result
  static Future<void> deserializePutBucketAcl(
    PutBucketAclResponse result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketAcl
  }

  // MARK: - GetBucketAcl

  /// Serialize GetBucketAcl request
  static Future<void> serializeGetBucketAcl(
    GetBucketAclRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketAcl
  }

  /// Deserialize GetBucketAcl result
  static Future<void> deserializeGetBucketAcl(
    GetBucketAclResponse result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'AccessControlPolicy',
    );

    AccessControlPolicy? accessControlPolicy;

    // Parse AccessControlList
    AccessControlList? accessControlList;
    final accessControlListData = body['AccessControlList'];
    if (accessControlListData is Map<String, dynamic>) {
      final grant = accessControlListData['Grant'] as String?;
      accessControlList = AccessControlList(grant: grant);
    }

    // Parse Owner
    Owner? owner;
    final ownerData = body['Owner'];
    if (ownerData is Map<String, dynamic>) {
      final displayName = ownerData['DisplayName'] as String?;
      final id = ownerData['ID'] as String?;
      owner = Owner(displayName: displayName, id: id);
    }

    // Create AccessControlPolicy
    accessControlPolicy = AccessControlPolicy(
      accessControlList: accessControlList,
      owner: owner,
    );

    result.accessControlPolicy = accessControlPolicy;
  }
}
