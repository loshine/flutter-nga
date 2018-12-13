import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

class Data {
  static final Data _singleton = Data._internal();

  Dio _dio;

  ObjectDB _forumDb;

  Dio get dio => _dio;

  ForumRepository _forumRepository;

  ForumRepository get forumRepository => _forumRepository;

  TopicRepository _topicRepository;

  TopicRepository get topicRepository => _topicRepository;

  factory Data() {
    return _singleton;
  }

  Data._internal();

  Future init() async {
    _dio = Dio();

    // 配置dio实例
    dio.options.baseUrl = "https://bbs.nga.cn";
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;
    _dio.options.responseType =
        ResponseType.STREAM; // 因为需要 gbk -> utf-8, 所以需要流的形式
    _dio.interceptor.request.onSend = (Options options) {
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
      debugPrint(response.data);
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
  }

  void close() async {
    // 清除所有网络访问
    _dio.clear();
    // 关闭数据库
    _forumDb.close();
  }
}
