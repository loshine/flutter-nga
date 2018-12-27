import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';

class TopicRepository {
  static final TopicRepository _singleton = TopicRepository._internal();

  factory TopicRepository() {
    return _singleton;
  }

  TopicRepository._internal();

  Future<TopicListData> getTopicList(int fid, int page) async {
    try {
      Response response = await Data()
          .dio
          .get("/thread.php?lite=js&noprefix&fid=$fid&page=$page");
      return TopicListData.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<TopicDetailData> getTopicDetail(int tid, int page) async {
    try {
      Response response = await Data()
          .dio
          .get("/read.php?lite=js&noprefix&tid=$tid&page=$page");
      return TopicDetailData.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }
}
