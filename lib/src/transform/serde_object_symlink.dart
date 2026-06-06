import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../models/model_object_symlink.dart';
import 'serde_extensions.dart';

/// Serialization and deserialization for object symlink operations
class SerdeObjectSymlink {
  /// Creates a SerdeObjectSymlink instance.
  SerdeObjectSymlink();

  // MARK: - PutSymlink

  /// Serialize PutSymlink request
  static Future<void> serializePutSymlink(
    PutSymlinkRequest request,
    OperationInput input,
  ) async {
    if (request.symlinkTarget != null) {
      input.headers['x-oss-symlink-target'] = request.symlinkTarget!;
    }

    if (request.objectAcl != null) {
      input.headers['x-oss-object-acl'] = request.objectAcl!;
    }

    if (request.storageClass != null) {
      input.headers['x-oss-storage-class'] = request.storageClass!;
    }

    if (request.forbidOverwrite != null) {
      input.headers['x-oss-forbid-overwrite'] = request.forbidOverwrite!
          .toStringValue();
    }
  }

  /// Deserialize PutSymlink result
  static Future<void> deserializePutSymlink(
    PutSymlinkResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutSymlink
  }

  // MARK: - GetSymlink

  /// Serialize GetSymlink request
  static Future<void> serializeGetSymlink(
    GetSymlinkRequest request,
    OperationInput input,
  ) async {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserialize GetSymlink result
  static Future<void> deserializeGetSymlink(
    GetSymlinkResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for GetSymlink
  }
}
