import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';

class TopicRepository {
  static final TopicRepository _singleton = TopicRepository._internal();

  factory TopicRepository() {
    return _singleton;
  }

  TopicRepository._internal();

  Future<List> getTopicList(int fid, int page) async {
    Response response = await Data().dio
        .get("/thread.php?lite=js&noprefix", data: {'fid': fid, 'page': page});
    return [];
  }
}
