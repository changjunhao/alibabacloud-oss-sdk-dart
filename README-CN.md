# Alibaba Cloud OSS SDK for Dart

[![pub package](https://img.shields.io/pub/v/alibabacloud_oss_sdk_dart.svg)](https://pub.dev/packages/alibabacloud_oss_sdk_dart)
[![license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

alibabacloud-oss-sdk-dart 是 OSS 在 Dart 编程语言下的 SDK。

## [English](README.md)

## 关于
> - 此 Dart SDK 基于[阿里云对象存储服务](https://www.aliyun.com/product/oss/)官方 API 构建。
> - 阿里云对象存储（Object Storage Service，简称 OSS），是阿里云对外提供的海量、安全、低成本、高可靠的云存储服务。
> - OSS 适合存放任意文件类型，适合各种网站、开发企业及开发者使用。
> - 使用此 SDK，用户可以方便地在任何应用、任何时间、任何地点上传、下载和管理数据。

## 功能特性

### 核心库 (`alibabacloud_oss_sdk_dart`)
- 存储空间基础操作（创建、删除、列举、详情、区域、统计）
- 存储空间 ACL 和版本控制
- 对象操作（上传、下载、复制、删除、追加、封闭追加、Head、Meta）
- 分片上传（初始化、上传分片、复制分片、完成、取消、列举分片）
- 预签名 URL 生成
- 列举操作分页器
- 对象软链接和标签
- CRC64 数据完整性校验
- 多签名版本支持（V1/V4）
- 灵活的凭证提供者
- 可配置的重试策略
- 日志支持

### 扩展库 (`alibabacloud_oss_sdk_extension`)
- 跨域资源共享（CORS）
- 服务端加密
- 日志管理
- Bucket Policy
- 防盗链
- 标签管理
- 传输加速
- 合规保留策略（WORM）
- 访问监控
- 归档直读
- HTTPS 配置
- 阻止公共访问
- 请求者付费
- 资源组
- 公共访问阻止

## 环境要求

- Dart SDK >= 3.11.0

## 安装方法

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  alibabacloud_oss_sdk_dart: ^1.1.0
```

然后执行：

```bash
dart pub get
```

## Library 入口

SDK 提供两个 library 入口，按需导入：

```dart
// 核心库 - 存储空间基础接口、对象接口、高级接口（分页器、预签名）
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

// 扩展库 - 存储空间配置类接口（CORS、加密、日志等）
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
```

> **说明：**
> - `alibabacloud_oss_sdk_dart` 提供了存储空间基础接口、所有对象接口和高级接口（如分页器、预签名）。
> - `alibabacloud_oss_sdk_extension` 提供了其他存储空间配置类接口，如跨域资源共享、加密、日志、策略等。

## 快速使用

#### 上传文件（Put Object）
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  // 使用 SDK 默认配置
  // 从环境变量加载访问凭证
  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final content = 'Hello, OSS!';
  final result = await client.putObject(
    PutObjectRequest(
      bucket: bucket,
      key: key,
      body: ByteStream.fromData(Uint8List.fromList(utf8.encode(content))),
    ),
  );

  print('上传完成, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

#### 下载文件（Get Object）
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.getObject(
    GetObjectRequest(bucket: bucket, key: key),
  );

  print('下载完成, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

#### 获取存储空间列表（List Buckets）
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.listBuckets(ListBucketsRequest());

  for (final bucket in result.buckets ?? []) {
    print('Bucket: ${bucket.name}');
  }
}
```

#### 删除文件（Delete Object）
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.deleteObject(
    DeleteObjectRequest(bucket: bucket, key: key),
  );

  print('删除完成, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

## 配置说明

`Configuration` 类支持链式调用：

```dart
final config = Configuration.defaultConfig()
    .withRegion('cn-hangzhou')
    .withCredentialsProvider(EnvironmentCredentialsProvider())
    .withEndpoint('https://oss-cn-hangzhou.aliyuncs.com')
    .withRetryMaxAttempts(5)
    .withTimeoutIntervalForRequest(Duration(seconds: 30))
    .withTimeoutIntervalForResource(Duration(hours: 24));
```

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `region` | 存储空间所在的地域 | - |
| `endpoint` | 自定义访问域名 | - |
| `credentialsProvider` | 用于签名请求的凭证提供者 | - |
| `retryMaxAttempts` | 最大重试次数 | 3 |
| `timeoutIntervalForRequest` | 请求超时时间 | 15s |
| `timeoutIntervalForResource` | 单个对象最大时间 | 24h |
| `httpProtocol` | HTTP 协议（HTTP/HTTPS） | HTTPS |
| `signerVersion` | 签名版本（V1/V4） | V4 |
| `usePathStyle` | 使用 Path 风格请求 | false |
| `useCname` | 使用 CNAME 请求模式 | false |
| `useDualStackEndpoint` | 使用双栈端点（IPv4/IPv6） | false |
| `useInternalEndpoint` | 使用内网端点 | false |
| `useAccelerateEndpoint` | 使用传输加速端点 | false |
| `enableUploadCRC64Validation` | 上传 CRC64 校验 | - |
| `enableDownloadCRC64Validation` | 下载 CRC64 校验 | - |

## 凭证配置

SDK 提供多种凭证提供者：

#### 静态凭证
```dart
final provider = StaticCredentialsProvider(
  accessKeyId: 'your-access-key-id',
  accessKeySecret: 'your-access-key-secret',
);
```

#### 环境变量
```dart
// 从以下环境变量读取: OSS_ACCESS_KEY_ID, OSS_ACCESS_KEY_SECRET, OSS_SESSION_TOKEN（可选）
final provider = EnvironmentCredentialsProvider();
```

#### STS Token（临时凭证）
```dart
final provider = StaticCredentialsProvider(
  accessKeyId: 'your-access-key-id',
  accessKeySecret: 'your-access-key-secret',
  securityToken: 'your-security-token',
);
```

#### 自定义凭证提供者
```dart
final provider = ClosureCredentialsProvider(() async {
  // 从自定义来源获取凭证
  return Credentials(
    accessKeyId: 'your-access-key-id',
    accessKeySecret: 'your-access-key-secret',
  );
});
```

#### 自动刷新凭证提供者
```dart
final provider = RefreshCredentialsProvider(
  fetcher: () async {
    // 获取新凭证（如从 STS 服务获取）
    return Credentials(
      accessKeyId: 'new-access-key-id',
      accessKeySecret: 'new-access-key-secret',
      securityToken: 'new-security-token',
      expiration: DateTime.now().add(Duration(hours: 1)),
    );
  },
);
```

## 使用示例

### 存储空间操作

```dart
// 创建存储空间
await client.putBucket(PutBucketRequest(bucket: 'my-bucket'));

// 获取存储空间信息
final info = await client.getBucketInfo(GetBucketInfoRequest(bucket: 'my-bucket'));

// 判断存储空间是否存在
final exists = await client.isBucketExist(IsBucketExistRequest(bucket: 'my-bucket'));

// 删除存储空间
await client.deleteBucket(DeleteBucketRequest(bucket: 'my-bucket'));
```

### 分片上传

```dart
// 初始化分片上传
final initResult = await client.initiateMultipartUpload(
  InitiateMultipartUploadRequest(bucket: bucket, key: key),
);
final uploadId = initResult.uploadId;

// 上传分片
final uploadPartResult = await client.uploadPart(
  UploadPartRequest(
    bucket: bucket,
    key: key,
    partNumber: 1,
    uploadId: uploadId,
    body: ByteStream.fromData(partData),
  ),
);

// 完成分片上传
await client.completeMultipartUpload(
  CompleteMultipartUploadRequest(
    bucket: bucket,
    key: key,
    uploadId: uploadId,
    completeAll: 'yes',
  ),
);
```

### 预签名 URL

```dart
// 生成下载预签名 URL
final result = await client.presignGetObject(
  GetObjectRequest(bucket: bucket, key: key),
);
print('预签名 URL: ${result.url}');
print('过期时间: ${result.expiration}');

// 生成上传预签名 URL
final putResult = await client.presignPutObject(
  PutObjectRequest(bucket: bucket, key: key),
);
```

### 对象标签

```dart
// 设置对象标签
await client.putObjectTagging(
  PutObjectTaggingRequest(
    bucket: bucket,
    key: key,
    tagging: Tagging(tagSet: TagSet(tags: [Tag(key: 'env', value: 'test')])),
  ),
);

// 获取对象标签
final tagging = await client.getObjectTagging(
  GetObjectTaggingRequest(bucket: bucket, key: key),
);
```

### 批量删除对象

```dart
// 在单次请求中删除多个对象。
// 注意：对象列表现在嵌套在 `delete: Delete(...)` 中。
final result = await client.deleteMultipleObjects(
  DeleteMultipleObjectsRequest(
    bucket: bucket,
    delete: Delete(
      objects: [
        DeleteObject(key: 'object-1'),
        DeleteObject(key: 'object-2'),
      ],
    ),
  ),
);

for (final deleted in result.deletedObjects ?? []) {
  print('已删除: ${deleted.key}');
}
```

### 封闭追加对象（Seal Append Object）

```dart
// 封闭可追加对象，之后不再允许追加数据。
// `position` 必须等于对象当前的长度。
await client.sealAppendObject(
  SealAppendObjectRequest(bucket: bucket, key: key, position: 1024),
);
```

### 取消操作

通过 Dio 的 `CancelToken` 取消任意进行中的操作：

```dart
import 'package:dio/dio.dart' show CancelToken;

final cancelToken = CancelToken();
final future = client.putObject(request, OperationOptions(cancelToken: cancelToken));

// 取消操作
cancelToken.cancel('user cancelled');
```

判断错误是否由取消引起：

```dart
try {
  await client.putObject(request, OperationOptions(cancelToken: cancelToken));
} on ClientError catch (e) {
  if (e.isCancelled) {
    print('操作已取消');
  }
}
```

## 测试

SDK 具有完善的测试覆盖：

| 类别 | 数量 | 说明 |
|------|------|------|
| 单元测试 | 537 | 序列化、凭证、签名、客户端逻辑 |
| 集成测试 | 227 | 全面覆盖所有 OSS 操作 |

### 运行测试

```bash
# 运行单元测试
dart test test/

# 运行集成测试
dart test integration_test/
```

> **说明：** 集成测试需要通过环境变量配置有效的 OSS 访问凭证。

## 更多示例

更多示例程序请参看 `example/` 目录。

### 运行示例

> - 进入示例程序目录 `example/`。
> - 通过环境变量配置访问凭证：
>   ```bash
>   export OSS_ACCESS_KEY_ID="your access key id"
>   export OSS_ACCESS_KEY_SECRET="your access key secret"
>   ```
> - 以 ListBuckets 为例，执行：
>   ```bash
>   dart run bin/list_buckets.dart --region cn-hangzhou
>   ```

## 许可协议
> - Apache-2.0，请参阅 [许可文件](LICENSE)
