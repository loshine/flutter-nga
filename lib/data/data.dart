import 'package:dio/dio.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';

class Data {
  static final Data _singleton = Data._internal();

  factory Data() {
    return _singleton;
  }

  Data._internal();

  static final dio = Dio();
  static final forumRepository = ForumRepository();
}
