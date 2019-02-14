import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/plugins/android_format_json.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

class Data {
  static final Data _singleton = Data._internal();

  Dio _dio;

  ObjectDB _forumDb;
  ObjectDB _userDb;

  Dio get dio => _dio;

  EmoticonRepository _emoticonRepository;

  EmoticonRepository get emoticonRepository => _emoticonRepository;

  ForumRepository _forumRepository;

  ForumRepository get forumRepository => _forumRepository;

  TopicRepository _topicRepository;

  TopicRepository get topicRepository => _topicRepository;

  UserRepository _userRepository;

  UserRepository get userRepository => _userRepository;

  factory Data() {
    return _singleton;
  }

  Data._internal();

  Future init() async {
    // 创建并初始化
    Directory appDocDir = await getApplicationDocumentsDirectory();

    _emoticonRepository = EmoticonRepository();

    String forumDbPath = [appDocDir.path, 'forum.db'].join('/');
    _forumDb = ObjectDB(forumDbPath);
    _forumRepository = ForumRepository();
    _forumRepository.init(_forumDb);

    _topicRepository = TopicRepository();

    String userDbPath = [appDocDir.path, 'user.db'].join('/');
    _userDb = ObjectDB(userDbPath);
    _userRepository = UserRepository();
    _userRepository.init(_userDb);

    _dio = Dio();

    _dio.cookieJar = PersistCookieJar([appDocDir.path, 'cookies'].join('/'));
    // 配置dio实例
    _dio.options.baseUrl = DOMAIN;
    _dio.options.connectTimeout = 10000; // 10s
    _dio.options.receiveTimeout = 10000; // 10s
//    _dio.onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) {
//        return "PROXY 172.25.108.10:8888";
//      };
//    };
    // 因为需要 gbk -> utf-8, 所以需要流的形式
    _dio.options.responseType = ResponseType.STREAM;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _dio.options.headers["User-Agent"] =
        "Nga_Official/2102([${androidInfo.brand} ${androidInfo.model}];Android${androidInfo.version.release})";
//        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36";
    _dio.options.headers["Accept-Encoding"] = "gzip";
    _dio.options.headers["Cache-Control"] = "max-age=0";
    _dio.options.headers["Connection"] = "Keep-Alive";

    _dio.interceptor.request.onSend = (Options options) async {
      options.headers.forEach((k, v) => debugPrint("$k : $v"));
      return options; //continue
      // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
      //
      // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    };
    _dio.interceptor.response.onSuccess = (Response response) async {
      // 在返回响应数据之前做一些预处理
      // gbk 编码 json 转 utf8
      Stream<List<int>> stream = response.data;
//      String responseBody = await stream
//          .transform(StreamTransformer.fromHandlers(
//              handleData: (data, EventSink sink) => sink.add(decodeGbk(data))))
//          .join();
      // flutter 的 gbk 库有少许字符解析不出来，暂时使用 Java 代替
      String responseBody = await stream.asyncMap((list) async {
        return await AndroidGbk.decode(list);
      }).join();
      // 处理一些可能导致错误的字符串
      // 直接制表符替换为 \t, \x 替换为 \\x
      responseBody =
          responseBody.replaceAll("\t", "\\t").replaceAll("\\x", "\\\\x");
      if (!responseBody.startsWith("{\"") && responseBody.startsWith("{")) {
        responseBody = await AndroidFormatJson.decode(responseBody);
      }
      debugPrint(
          "request url : ${response.request.baseUrl + response.request.path}\n" +
              "request data : ${response.request.data.toString()}\n" +
              "response data : $responseBody");
      Map<String, dynamic> map;
      try {
        map = json.decode(responseBody);
      } catch (error) {
        response.data = responseBody;
        return response;
      }
      // 如果是 api 错误，抛出错误内容
      if (map["data"] is Map<String, dynamic> &&
          map["data"].containsKey("__MESSAGE")) {
        String errorMessage = map["data"]["__MESSAGE"]["1"];
        throw DioError(
          response: response,
          message: errorMessage,
          type: DioErrorType.RESPONSE,
        );
      }
      // 点赞时的错误
      if (map["error"] is Map) {
        Map<String, dynamic> err = map["error"];
        if (err["0"] is String) {
          throw DioError(
            response: response,
            message: err["0"],
            type: DioErrorType.RESPONSE,
          );
        }
      }
      // 上传附件时的错误
      if (map["error"] is String) {
        String errorMessage = map["error"];
        throw DioError(
          response: response,
          message: errorMessage,
          type: DioErrorType.RESPONSE,
        );
      }
      response.data = map["data"];
      return response;
    };
    _dio.interceptor.response.onError = (DioError e) {
      // 当请求失败时做一些预处理
      return e;
    };
  }

  void close() async {
    // 清除所有网络访问
    _dio.clear();
    // 关闭数据库
    _forumDb.close();
    _userDb.close();
  }
}
