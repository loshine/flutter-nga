import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 把动态 JSON 收成 `Map<String, dynamic>`，失败时打出字段路径便于定位。
Map<String, dynamic> asJsonMap(dynamic value, String path) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (error, stack) {
      logJsonTypeMismatch(path, value, error: error, stack: stack);
      throw FormatException(
        'JSON $path 无法转为 Map<String, dynamic>，实际类型 ${value.runtimeType}',
      );
    }
  }
  logJsonTypeMismatch(path, value);
  throw FormatException(
    'JSON $path 期望 Map，实际是 ${value.runtimeType}',
  );
}

/// 值为 null 时返回 null；非 Map 仍会记日志并抛错。
Map<String, dynamic>? asJsonMapOrNull(dynamic value, String path) {
  if (value == null) return null;
  return asJsonMap(value, path);
}

void logJsonTypeMismatch(
  String path,
  dynamic value, {
  Object? error,
  StackTrace? stack,
}) {
  final preview = _preview(value);
  final message =
      '[json] $path 期望 Map<String, dynamic>，实际 ${value.runtimeType}: $preview';
  debugPrint(message);
  developer.log(
    message,
    name: 'nga.json',
    error: error ?? message,
    stackTrace: stack ?? StackTrace.current,
  );
}

String _preview(dynamic value) {
  final text = value.toString().replaceAll(RegExp(r'\s+'), ' ');
  if (text.length <= 200) return text;
  return '${text.substring(0, 200)}…';
}
