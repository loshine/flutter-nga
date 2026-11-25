import 'package:dio/dio.dart';
import 'package:flutter_nga/utils/error_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('errorMessage', () {
    test('returns fallback for null and blank strings', () {
      expect(errorMessage(null), '操作失败');
      expect(errorMessage(''), '操作失败');
      expect(errorMessage('   '), '操作失败');
      expect(errorMessage(null, fallback: '自定义'), '自定义');
    });

    test('returns plain strings as-is', () {
      expect(errorMessage('网络错误'), '网络错误');
    });

    test('prefers DioException.error over message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: '服务器拒绝访问',
        message: 'ignored message',
        type: DioExceptionType.unknown,
      );
      expect(errorMessage(error), '服务器拒绝访问');
    });

    test('falls back to DioException.message when error is empty', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: '连接超时',
        type: DioExceptionType.connectionTimeout,
      );
      expect(errorMessage(error), '连接超时');
    });

    test('falls back to statusMessage when error and message are empty', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
          statusMessage: 'Service Unavailable',
        ),
        type: DioExceptionType.badResponse,
      );
      expect(errorMessage(error), 'Service Unavailable');
    });

    test('uses Exception.toString for generic exceptions', () {
      expect(errorMessage(Exception('boom')), 'Exception: boom');
    });
  });

  group('isAuthRequiredError', () {
    test('detects NGA unauthenticated error messages', () {
      for (final msg in [
        '未登录',
        '1:未登录',
        '请登录后访问',
        '15:访客不能直接访问',
        '未登录时服务端返回数据不完整，请登录后重试',
      ]) {
        final err = DioException(
          requestOptions: RequestOptions(path: '/thread.php'),
          error: msg,
        );
        expect(isAuthRequiredError(err), isTrue, reason: msg);
        expect(isAuthRequiredError(msg), isTrue, reason: msg);
      }
    });

    test('returns false for non-auth errors', () {
      expect(isAuthRequiredError(null), isFalse);
      expect(isAuthRequiredError('网络错误，请稍候重试。'), isFalse);
      expect(isAuthRequiredError(Exception('连接超时')), isFalse);
    });
  });
}
