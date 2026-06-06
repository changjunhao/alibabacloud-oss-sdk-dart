import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../models/model_object_acl.dart';
import '../models/model_shared.dart';
import 'serde_functions.dart';

/// Extension for object ACL operations serialization and deserialization
extension SerdeObjectAcl on Serde {
  // MARK: - PutObjectAcl

  /// Serialize PutObjectAcl request
  static Future<void> serializePutObjectAcl(
    PutObjectAclRequest request,
    OperationInput input,
  ) async {
    if (request.objectAcl != null) {
      input.headers['x-oss-object-acl'] = request.objectAcl!;
    }

    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserialize PutObjectAcl result
  static Future<void> deserializePutObjectAcl(
    PutObjectAclResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutObjectAcl
    // versionId is accessed via getter from headers
  }

  // MARK: - GetObjectAcl

  /// Serialize GetObjectAcl request
  static Future<void> serializeGetObjectAcl(
    GetObjectAclRequest request,
    OperationInput input,
  ) async {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserialize GetObjectAcl result
  static Future<void> deserializeGetObjectAcl(
    GetObjectAclResult result,
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
