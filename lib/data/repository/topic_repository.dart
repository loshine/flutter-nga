import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:path/path.dart';

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

  Future<String> getAuthCode(int fid, int tid, String action) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
            "post.php?lite=js&noprefix&fid=$fid&tid=$tid&action=$action",
          );
      return response.data["auth"];
    } catch (error) {
      rethrow;
    }
  }

  Future<String> uploadAttachment(
    int fid,
    String authCode,
    File file,
  ) async {
    try {
      var fileName = basename(file.path);
      final formData = FormData.from({
        "attachment_file1": UploadFileInfo(file, fileName,
            contentType: ContentType.parse("image/jpeg")),
        "attachment_file1_url_utf8_name": fileName,
        "fid": "$fid",
        "auth": authCode,
        "func": "upload",
        "v2": "1",
        "lite": "js",
        // 1 是自动缩图
        "attachment_file1_auto_size": "",
        //水印位置tl/tr/bl/br 左上右上左下右下 不设为无水印
        "attachment_file1_watermark": "",
        "attachment_file1_dscp": "",
        "attachment_file1_img": "1",
        "origin_domain": "bbs.ngacn.cc",
        "noprefix": "",
      });
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .post("http://img.nga.178.com:8080/attach.php", data: formData);
      return response.data["url"];
    } catch (error) {
      rethrow;
    }
  }
}
