import 'package:dio/dio.dart';

/// Extracts a short, user-facing message from an arbitrary error.
///
/// Prefer [DioException.error] (where this app puts server text) over
/// [DioException.message], then fall back to [Object.toString].
String errorMessage(Object? error, {String fallback = '操作失败'}) {
  if (error == null) return fallback;

  if (error is String) {
    final text = error.trim();
    return text.isEmpty ? fallback : text;
  }

  if (error is DioException) {
    for (final candidate in [
      error.error,
      error.message,
      error.response?.statusMessage,
    ]) {
      final text = _nonEmpty(candidate);
      if (text != null) return text;
    }
  }

  final text = error.toString().trim();
  return text.isEmpty ? fallback : text;
}

/// 判断错误是否属于需要登录才能访问的场景（如 NGA 返回「未登录」「请登录后访问」等）。
bool isAuthRequiredError(Object? error) {
  final msg = errorMessage(error, fallback: '');
  if (msg.isEmpty) return false;
  return msg.contains('未登录') ||
      msg.contains('请登录') ||
      msg.contains('登录后') ||
      msg.contains('访客不能直接访问');
}

String? _nonEmpty(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
