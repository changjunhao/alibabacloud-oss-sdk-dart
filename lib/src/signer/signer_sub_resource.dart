/// List of resource flags that need to be included in signature calculation
const List<String> signerResourceFlag = [
  'acl',
  'bucketInfo',
  'location',
  'stat',
  'delete',
  'append',
  'tagging',
  'objectMeta',
  'uploads',
  'uploadId',
  'partNumber',
  'security-token',
  'position',
  'response-content-type',
  'response-content-language',
  'response-expires',
  'response-cache-control',
  'response-content-disposition',
  'response-content-encoding',
  'restore',
  'callback',
  'callback-var',
  'versions',
  'versioning',
  'versionId',
  'sequential',
  'continuation-token',
  'regionList',
  'cloudboxes',
  'symlink',
  'cleanRestoredObject',
];

/// List of response flags for content type handling
const List<String> signerResponseFlag = [
  'response-content-type',
  'response-content-language',
  'response-expires',
  'response-cache-control',
  'response-content-disposition',
  'response-content-encoding',
];

/// Process flag for OSS operations
const String signerProcessFlag = 'x-oss-process';

/// Access control flag prefix
const String signerAccessFlag = 'x-oss-ac-';
