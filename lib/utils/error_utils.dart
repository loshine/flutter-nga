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

String? _nonEmpty(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
