import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

class NgaDioConfigurator {
  /// [enableLogging] 默认仅在 debug 构建开启：PrettyDioLogger 会把请求头
  /// （含 uid/cid 登录 Cookie）打印到 logcat / 系统日志，release 下必须关闭。
  NgaDioConfigurator(this._loadDefaultUser, {this.enableLogging = kDebugMode});

  /// 在 [RequestOptions.extra] 中置为 true 时，响应拦截器跳过 GBK 解码与
  /// JSON 解包，原样返回字节（用于下载图片等二进制资源）。
  static const String rawResponseKey = 'nga_raw_response';

  final Future<CacheUser?> Function() _loadDefaultUser;
  final bool enableLogging;
  final GbkCodec _gbk = const GbkCodec(allowMalformed: true);

  void configure(Dio dio) {
    dio.options.connectTimeout = const Duration(milliseconds: 10000);
    dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    dio.options.responseType = ResponseType.bytes;
    dio.options.headers["Accept-Encoding"] = "gzip";
    dio.options.headers["Cache-Control"] = "max-age=0";
    dio.options.headers["Connection"] = "Keep-Alive";

    dio.interceptors.add(_createMainInterceptor());
    if (enableLogging) {
      dio.interceptors.add(PrettyDioLogger(responseBody: false));
    }
  }

  InterceptorsWrapper _createMainInterceptor() {
    return InterceptorsWrapper(
      onRequest: _handleRequest,
      onResponse: _handleResponse,
      onError: _handleError,
    );
  }

  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers["Cookie"] == null && shouldAttachLoginCookie(options)) {
      final user = await _loadDefaultUser();
      if (user != null) {
        options.headers["Cookie"] = "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
      }
    }
    handler.next(options);
  }

  /// 只有请求 NGA 自有域名或当前 baseUrl（含用户自定义地址）时才携带登录
  /// Cookie，避免把凭据发给帖子中引用的第三方图床等外部站点。
  @visibleForTesting
  static bool shouldAttachLoginCookie(RequestOptions options) {
    final host = options.uri.host.toLowerCase();
    if (host.isEmpty) return false;
    if (isNgaHost(host)) return true;
    final baseHost = Uri.tryParse(options.baseUrl)?.host.toLowerCase() ?? '';
    return baseHost.isNotEmpty && host == baseHost;
  }

  Future<void> _handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_isRawResponse(response.requestOptions)) {
      handler.next(response);
      return;
    }
    response.headers.set('Content-Type', "application/json; charset=GBK");
    final responseBody = _formatResponseBody(response);
    final map = _tryDecodeMap(responseBody);
    if (map == null) {
      response.data = responseBody;
      handler.next(response);
      return;
    }

    final dioError = _preHandleServerError(response, map);
    if (dioError != null) {
      handler.reject(dioError);
      return;
    }

    response.data = map.containsKey("data") ? map["data"] : map;
    handler.next(response);
  }

  Future<void> _handleError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(e.toString());
    if (e.error is IOException) {
      handler.next(
        DioException(
          requestOptions: e.requestOptions,
          error: "网络错误，请稍候重试。",
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }
    if (_isRawResponse(e.requestOptions) ||
        e.response == null ||
        e.response!.data == null) {
      handler.next(e);
      return;
    }

    final responseBody = _formatResponseBody(e.response!);
    final map = _tryDecodeMap(responseBody);
    if (map == null) {
      handler.next(e);
      return;
    }

    final dioError = _preHandleServerError(e.response, map);
    handler.next(dioError ?? e);
  }

  bool _isRawResponse(RequestOptions options) =>
      options.extra[rawResponseKey] == true;

  Map<String, dynamic>? _tryDecodeMap(String responseBody) {
    try {
      return json.decode(responseBody);
    } catch (err) {
      debugPrint(err.toString());
      return null;
    }
  }

  String _formatResponseBody(Response response) {
    final bytes = response.data as List<int>;
    var responseBody = _gbk.decode(bytes);
    responseBody = code_utils.stripLow(responseBody);
    responseBody = responseBody
        .replaceAll("\t", "\\t")
        .replaceAll("\\x", "\\\\x")
        .replaceAll(
          "<html><head><meta http-equiv='Content-Type' content='text/html; charset=GBK'></head><body><script>",
          "",
        )
        .replaceAll("</script></body></html>", "")
        .replaceAll("window.script_muti_get_var_store=", "");
    if (response.requestOptions.path.contains("__lib=noti") &&
        response.requestOptions.path.contains("__act=get_all")) {
      responseBody = code_utils.fixUnquotedJsonKeys(responseBody);
    }
    return responseBody;
  }

  DioException? _preHandleServerError(
    Response? response,
    Map<String, dynamic> map,
  ) {
    if (response == null) return null;
    if (map["data"] is Map<String, dynamic> &&
        map["data"].containsKey("__MESSAGE")) {
      final errorMessage = map["data"]["__MESSAGE"]["1"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    if (map["error"] is Map) {
      final err = map["error"] as Map<String, dynamic>;
      if (err["0"] is String) {
        return DioException(
          requestOptions: response.requestOptions,
          error: err["0"],
          type: DioExceptionType.unknown,
        );
      }
    }
    if (map["error"] is String) {
      final errorMessage = map["error"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    return null;
  }
}
