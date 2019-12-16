import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/toggle_like_reaction.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:path/path.dart';

class TopicRepository {
  static final TopicRepository _singleton = TopicRepository._internal();

  static const _RESULT_START_TAG = "<span style='color:#aaa'>&gt;</span>";
  static const _RESULT_END_TAG = "<br/>";

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

  Future<Map<String, dynamic>> uploadAttachment(
    int fid,
    String authCode,
    File file,
  ) async {
    try {
      final fileName = basename(file.path);
      final formData = FormData.fromMap({
        "attachment_file1":
            MultipartFile.fromFile(file.path, filename: fileName),
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
      return response.data;
    } catch (error) {
      rethrow;
    }
  }

  Future<String> checkCreateTopic(int fid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?fid=$fid&__output=8&lite=js&action=new");
      return response.data['auth'];
    } catch (error) {
      rethrow;
    }
  }

  Future<String> createTopic(int fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck) async {
    final postData = "step=2"
        "&post_content=${await AndroidGbk.urlEncode(content)}"
        "&action=new"
        "&post_subject=${await AndroidGbk.urlEncode(subject) ?? ""}"
        "&fid=$fid${isAnonymous ? "anony=1" : ""}"
        "${!codeUtils.isStringEmpty(attachments) ? "&attachments=$attachments" : ""}"
        "${!codeUtils.isStringEmpty(attachmentsCheck) ? "&attachments_check=$attachmentsCheck" : ""}";
    try {
      final options = Options();
      options.contentType = "application/x-www-form-urlencoded";
      Response<String> response = await Data().dio.post(
            "post.php",
            data: postData,
            options: options,
          );
      final html = response.data;
      int start = html.indexOf(_RESULT_START_TAG);
      if (start == -1) return "发帖失败";
      start += _RESULT_START_TAG.length;
      int end = html.indexOf(_RESULT_END_TAG, start);
      if (end < 0) return "发帖失败";
      return html.substring(start, end);
    } catch (error) {
      rethrow;
    }
  }

  Future<String> createReply(int tid, int fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck) async {
    final postData = "step=2"
        "&post_content=${await AndroidGbk.urlEncode(content)}"
        "&tid=$tid"
        "&action=reply"
        "&post_subject=${await AndroidGbk.urlEncode(subject) ?? ""}"
        "&fid=$fid${isAnonymous ? "anony=1" : ""}"
        "${!codeUtils.isStringEmpty(attachments) ? "&attachments=$attachments" : ""}"
        "${!codeUtils.isStringEmpty(attachmentsCheck) ? "&attachments_check=$attachmentsCheck" : ""}";
    try {
      final options = Options();
      options.contentType = "application/x-www-form-urlencoded";
      Response<String> response = await Data().dio.post(
            "post.php",
            data: postData,
            options: options,
          );
      final html = response.data;
      int start = html.indexOf(_RESULT_START_TAG);
      if (start == -1) return "发帖失败";
      start += _RESULT_START_TAG.length;
      int end = html.indexOf(_RESULT_END_TAG, start);
      if (end < 0) return "发帖失败";
      return html.substring(start, end);
    } catch (error) {
      rethrow;
    }
  }

  Future<ToggleLikeReaction> likeReply(int tid, int pid) async {
    final postData =
        "__output=8&__lib=topic_recommend&__act=add&raw=3&pid=$pid&value=1&tid=$tid";
    try {
      final options = Options();
      options.contentType = "application/x-www-form-urlencoded";
      Response<Map<String, dynamic>> response = await Data().dio.post(
            "nuke.php",
            data: postData,
            options: options,
          );
      return ToggleLikeReaction.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }

  Future<ToggleLikeReaction> dislikeReply(int tid, int pid) async {
    final postData =
        "__output=8&__lib=topic_recommend&__act=add&raw=3&pid=$pid&value=-1&tid=$tid";
    try {
      final options = Options();
      options.contentType = "application/x-www-form-urlencoded";
      Response<Map<String, dynamic>> response = await Data().dio.post(
            "nuke.php",
            data: postData,
            options: options,
          );
      return ToggleLikeReaction.fromJson(response.data);
    } catch (error) {
      rethrow;
    }
  }
}
