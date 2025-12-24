import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/data/repository/resource_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class Data {
  static final Data _singleton = Data._internal();

  Dio? _dio;

  Database? _database;

  Dio get dio => _dio!;

  Database get database => _database!;

  JavascriptRuntime? _jsEngine;

  JavascriptRuntime get jsEngine {
    if (_jsEngine == null) {
      _jsEngine = getJavascriptRuntime();
    }
    return _jsEngine!;
  }

  EmoticonRepository get emoticonRepository => EmoticonDataRepository();

  ForumRepository get forumRepository => ForumDataRepository(database);

  MessageRepository get messageRepository => MessageDataRepository();

  ResourceRepository get resourceRepository => ResourceDataRepository();

  TopicRepository get topicRepository => TopicDataRepository(database);

  UserRepository get userRepository => UserDataRepository(database);

  final _gbk = const GbkCodec(allowMalformed: true);

  factory Data() {
    return _singleton;
  }

  Data._internal();

  Future init() async {
    // 创建并初始化
    Directory appDocDir = await getApplicationDocumentsDirectory();
    DatabaseFactory dbFactory = databaseFactoryIo;

    String forumDbPath = [appDocDir.path, 'main.db'].join('/');
    _database = await dbFactory.openDatabase(forumDbPath);

    _dio = Dio();

    // 配置dio实例
    dio.options.baseUrl = DOMAIN;
    dio.options.connectTimeout = const Duration(milliseconds: 10000); // 10s
    dio.options.receiveTimeout = const Duration(milliseconds: 10000); // 10s
//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//        (HttpClient client) {
//      client.findProxy = (uri) {
//        return "PROXY 192.168.50.88:8899";
//      };
//    };
    // 因为需要 gbk -> utf-8, 所以需要流的形式
    dio.options.responseType = ResponseType.bytes;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // 该特殊 UA 可以让访客访问
    String userAgent;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      userAgent =
          "Nga_Official/90306([${androidInfo.brand} ${androidInfo.model}];"
          "Android${androidInfo.version.release})";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      userAgent =
          "NGA_skull/7.3.1(${iosInfo.utsname.machine};iOS ${iosInfo.systemVersion})";
    } else {
      userAgent = "Nga_Official/90306";
    }
    dio.options.headers["User-Agent"] = userAgent;
    dio.options.headers["Accept-Encoding"] = "gzip";
    dio.options.headers["Cache-Control"] = "max-age=0";
    dio.options.headers["Connection"] = "Keep-Alive";

    dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        // 在请求被发送之前做一些事情
        // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
        // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
        //
        // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
        // 这样请求将被中止并触发异常，上层catchError会被调用。
        final user = await userRepository.getDefaultUser();
        if (user != null && options.headers["Cookie"] == null) {
          options.headers["Cookie"] =
              "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
        }
        return handler.next(options); //continue
      },
      onResponse: (
        Response response,
        ResponseInterceptorHandler handler,
      ) async {
        response.headers.set('Content-Type', "application/json; charset=GBK");
        String responseBody = _formatResponseBody(response);
        Map<String, dynamic>? map;
        try {
          map = json.decode(responseBody);
        } catch (err) {
          debugPrint(err.toString());
          response.data = responseBody;
          return handler.next(response);
        }
        DioException? dioError = _preHandleServerError(response, map!);
        if (dioError != null) {
          handler.reject(dioError);
        }
        // 上传附件的时候没有 data
        if (map.containsKey("data")) {
          response.data = map["data"];
        } else {
          response.data = map;
        }
        return handler.next(response);
      },
      onError: (
        DioException e,
        ErrorInterceptorHandler handler,
      ) async {
        debugPrint(e.toString());
        if (e.error is IOException) {
          return handler.next(DioException(
            requestOptions: e.requestOptions,
            error: "网络错误，请稍候重试。",
            type: DioExceptionType.unknown,
          ));
        }
        if (e.response != null && e.response!.data != null) {
          String responseBody = _formatResponseBody(e.response!);
          Map<String, dynamic>? map;
          try {
            map = json.decode(responseBody);
          } catch (err) {
            debugPrint(err.toString());
            return handler.next(e);
          }
          DioException? dioError = _preHandleServerError(e.response, map!);
          if (dioError != null) {
            return handler.next(dioError);
          }
        }
        return handler.next(e);
      },
    ));
    dio.interceptors.add(PrettyDioLogger());
  }

  /// 格式化响应,处理一些不兼容问题
  String _formatResponseBody(Response response) {
    // 在返回响应数据之前做一些预处理
    // gbk 编码 json 转 utf8
    List<int> bytes = response.data;
    String responseBody = _gbk.decode(bytes);
    // 处理一些可能导致错误的字符串
    // 去除 control characters
    responseBody = codeUtils.stripLow(responseBody);
    // 直接制表符替换为 \t, \x 替换为 \\x
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
      // js engine 格式化 json
      responseBody =
          jsEngine.evaluate('JSON.stringify($responseBody)').stringResult;
    }
    return responseBody;
  }

  /// 预处理服务器业务错误
  DioException? _preHandleServerError(
      Response? response, Map<String, dynamic> map) {
    if (response == null) return null;
    // 如果是 api 错误，抛出错误内容
    if (map["data"] is Map<String, dynamic> &&
        map["data"].containsKey("__MESSAGE")) {
      String? errorMessage = map["data"]["__MESSAGE"]["1"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    // 点赞时的错误
    if (map["error"] is Map) {
      Map<String, dynamic> err = map["error"];
      if (err["0"] is String) {
        return DioException(
          requestOptions: response.requestOptions,
          error: err["0"],
          type: DioExceptionType.unknown,
        );
      }
    }
    // 上传附件时的错误
    if (map["error"] is String) {
      String? errorMessage = map["error"];
      return DioException(
        requestOptions: response.requestOptions,
        error: errorMessage,
        type: DioExceptionType.unknown,
      );
    }
    return null;
  }

  void close() async {
    // 关闭数据库
    _database?.close();
  }
}
