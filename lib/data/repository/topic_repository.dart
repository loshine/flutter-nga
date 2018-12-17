import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';

class TopicRepository {
  static final TopicRepository _singleton = TopicRepository._internal();

  factory TopicRepository() {
    return _singleton;
  }

  TopicRepository._internal();

  Future<TopicListData> getTopicList(int fid, int page) async {
    try {
      Response response = await Data().dio.get("/thread.php?lite=js&noprefix",
          data: {'fid': fid, 'page': page});
      return TopicListData.fromJson(response.data);
    } catch (err) {
      debugPrint(err.message);
      throw err;
    }
  }
}
