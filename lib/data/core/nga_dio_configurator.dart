import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

class NgaDioConfigurator {
  NgaDioConfigurator(this._loadDefaultUser);

  final Future<CacheUser?> Function() _loadDefaultUser;
  final GbkCodec _gbk = const GbkCodec(allowMalformed: true);

  void configure(Dio dio) {
    dio.options.connectTimeout = const Duration(milliseconds: 10000);
    dio.options.receiveTimeout = const Duration(milliseconds: 10000);
    dio.options.responseType = ResponseType.bytes;
    dio.options.headers["Accept-Encoding"] = "gzip";
    dio.options.headers["Cache-Control"] = "max-age=0";
    dio.options.headers["Connection"] = "Keep-Alive";

    dio.interceptors.add(_createMainInterceptor());
    dio.interceptors.add(PrettyDioLogger());
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
    final user = await _loadDefaultUser();
    if (user != null && options.headers["Cookie"] == null) {
      options.headers["Cookie"] = "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
    }
    handler.next(options);
  }

  Future<void> _handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
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
      handler.next(DioException(
        requestOptions: e.requestOptions,
        error: "网络错误，请稍候重试。",
        type: DioExceptionType.unknown,
      ));
      return;
    }
    if (e.response == null || e.response!.data == null) {
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
            "")
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
