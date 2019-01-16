import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';

class TopicRepository {
  static final TopicRepository _singleton = TopicRepository._internal();

  factory TopicRepository() {
    return _singleton;
  }

  TopicRepository._internal();

  Future<TopicListData> getTopicList(int fid, int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("thread.php?lite=js&noprefix&fid=$fid&page=$page");
      return TopicListData.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<TopicDetailData> getTopicDetail(int tid, int page) async {
    try {
      Response<Map<String, dynamic>> response =
          await Data().dio.get("read.php?lite=js&noprefix&tid=$tid&page=$page");
      return TopicDetailData.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<TopicTag>> getTopicTagList(int fid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?fid=$fid&__output=8&__lib=topic_key&__act=get");
      List<TopicTag> list = [];
      Map<String, dynamic> tagMap = response.data["0"];
      tagMap.forEach((k, v) {
        list.add(TopicTag(id: int.tryParse(k), content: v["0"]));
      });
      return list;
    } catch (error) {
      rethrow;
    }
  }
}
