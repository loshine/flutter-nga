import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

class Data {
  static final Data _singleton = Data._internal();

  Dio _dio;

  ObjectDB _forumDb;
  ObjectDB _userDb;

  Dio get dio => _dio;

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
    _dio = Dio();

    // 配置dio实例
    _dio.options.baseUrl = "https://bbs.nga.cn";
    _dio.options.connectTimeout = 5000; //5s
    _dio.options.receiveTimeout = 3000;
    _dio.options.responseType =
        ResponseType.PLAIN; // 因为需要 gbk -> utf-8, 所以需要流的形式
    _dio.interceptor.request.onSend = (Options options) async {
      try {
        final user = await userRepository.getDefaultUser();
        options.headers["Cookie"] = "$TAG_UID=${user.uid};$TAG_CID=${user.cid}";
      } catch (e) {
        print("no login user");
      }
      // 在请求被发送之前做一些事情
      return options; //continue
      // 如果你想完成请求并返回一些自定义数据，可以返回一个`Response`对象或返回`dio.resolve(data)`。
      // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义数据data.
      //
      // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象，或返回`dio.reject(errMsg)`，
      // 这样请求将被中止并触发异常，上层catchError会被调用。
    };
    _dio.interceptor.response.onSuccess = (Response response) {
      // 在返回响应数据之前做一些预处理
      // gbk 编码 json 转 utf8
      String jsonString = decodeGbk(response.data.codeUnits);
      // 处理一些可能导致错误的字符串
      // 直接制表符替换为 \t, \x 替换为 \\x
      jsonString =
          jsonString.replaceAll("\t", "\\t").replaceAll("\\x", "\\\\x");
      Map<String, dynamic> map = json.decode(jsonString);
      debugPrint(
          "request url : ${response.request.baseUrl + response.request.path}\n" +
              "request data : ${response.request.data.toString()}\n" +
              "response data : $jsonString");
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
      response.data = map["data"];
      return response;
    };
    _dio.interceptor.response.onError = (DioError e) {
      // 当请求失败时做一些预处理
      return e;
    };

    // 创建并初始化
    Directory appDocDir = await getApplicationDocumentsDirectory();

    String forumDbPath = [appDocDir.path, 'forum.db'].join('/');
    _forumDb = ObjectDB(forumDbPath);
    _forumRepository = ForumRepository();
    _forumRepository.init(_forumDb);

    _topicRepository = TopicRepository();

    String userDbPath = [appDocDir.path, 'user.db'].join('/');
    _userDb = ObjectDB(userDbPath);
    _userRepository = UserRepository();
    _userRepository.init(_userDb);
  }

  void close() async {
    // 清除所有网络访问
    _dio.clear();
    // 关闭数据库
    _forumDb.close();
    _userDb.close();
  }
}
