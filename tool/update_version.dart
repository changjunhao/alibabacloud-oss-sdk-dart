#!/usr/bin/env dart

/// 构建脚本：自动更新SdkInfo中的版本信息
/// 使用方法：dart run tool/update_version.dart [version]
/// 例如：dart run tool/update_version.dart 1.2.3
library;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  try {
    // 获取版本号
    String? newVersion;
    if (args.isNotEmpty) {
      newVersion = args[0];
    } else {
      // 从pubspec.yaml读取版本
      newVersion = await getVersionFromPubspec();
    }

    if (newVersion == null) {
      print('错误：无法获取版本号');
      print('使用方法：dart run tool/update_version.dart [version]');
      exit(1);
    }

    // 验证版本格式
    if (!isValidVersion(newVersion)) {
      print('错误：版本格式无效。请使用 x.y.z 或 x.y.z-tag 格式');
      exit(1);
    }

    // 解析版本号
    final versionParts = parseVersion(newVersion);

    // 更新SdkInfo文件
    await updateSdkInfo(versionParts);

    print('✅ 版本信息已更新为: $newVersion');
    print('📁 文件已更新: lib/src/sdk_info.dart');
  } catch (e) {
    print('❌ 更新失败: $e');
    exit(1);
  }
}

/// 从pubspec.yaml读取版本号
Future<String?> getVersionFromPubspec() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return null;
    }

    final content = await pubspecFile.readAsString();
    final yamlMap = loadYaml(content) as YamlMap;
    return yamlMap['version']?.toString();
  } catch (e) {
    return null;
  }
}

/// 验证版本格式
bool isValidVersion(String version) {
  final regex = RegExp(r'^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?$');
  return regex.hasMatch(version);
}

/// 解析版本号
Map<String, String> parseVersion(String version) {
  final parts = version.split('-');
  final versionPart = parts[0];
  final tag = parts.length > 1 ? '-${parts.sublist(1).join('-')}' : '';

  final versionNumbers = versionPart.split('.');

  return {
    'major': versionNumbers[0],
    'minor': versionNumbers[1],
    'patch': versionNumbers[2],
    'tag': tag,
    'full': version,
  };
}

/// 更新SdkInfo文件
Future<void> updateSdkInfo(Map<String, String> versionParts) async {
  final sdkInfoPath = path.join('lib', 'src', 'sdk_info.dart');
  final sdkInfoFile = File(sdkInfoPath);

  if (!sdkInfoFile.existsSync()) {
    throw Exception('SdkInfo文件不存在: $sdkInfoPath');
  }

  String content = await sdkInfoFile.readAsString();

  // 获取当前时间戳
  final buildTime = DateTime.now().toUtc().toIso8601String();

  // 更新版本信息
  content = content.replaceAll(
    RegExp(r"static const String _major = '[^']*';"),
    "static const String _major = '${versionParts['major']}';",
  );

  content = content.replaceAll(
    RegExp(r"static const String _minor = '[^']*';"),
    "static const String _minor = '${versionParts['minor']}';",
  );

  content = content.replaceAll(
    RegExp(r"static const String _patch = '[^']*';"),
    "static const String _patch = '${versionParts['patch']}';",
  );

  content = content.replaceAll(
    RegExp(r"static const String _tag = '[^']*';"),
    "static const String _tag = '${versionParts['tag']}';",
  );

  content = content.replaceAll(
    RegExp(r"static const String _buildTime = '[^']*';"),
    "static const String _buildTime = '$buildTime';",
  );

  // 写回文件
  await sdkInfoFile.writeAsString(content);
}
