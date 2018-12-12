import 'package:dio/dio.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:objectdb/objectdb.dart';

class Data {
  static final Data _singleton = Data._internal();

  static Dio _dio;

  static Dio get dio => _dio;

  static ForumRepository _forumRepository;

  static ForumRepository get forumRepository => _forumRepository;

  factory Data() {
    return _singleton;
  }

  Data._internal();

  static void init() async {
    _dio = Dio();

    // 创建并初始化
    _forumRepository = ForumRepository();
    _forumRepository.init();
  }

  static void close() async {
    // 清除所有网络访问
    _dio.clear();
    // 关闭数据库
    forumRepository.close();
  }
}
