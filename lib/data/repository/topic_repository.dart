import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/toggle_like_reaction.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';

abstract class TopicRepository {
  Future<TopicListData> getTopicList(int fid, int page,
      {bool recommend = false, int? type = 0});

  Future<TopicDetailData> getTopicDetail(int tid, int page);

  Future<TopicDetailData> getTopicReply(int? pid);

  Future<TopicListData> getFavouriteTopicList(int page);

  Future<String?> addFavouriteTopic(int? tid);

  Future<String?> deleteFavouriteTopic(int? tid, int? page);

  Future<List<TopicTag>> getTopicTagList(int fid);

  Future<String?> getAuthCode(int? fid, int? tid, String action);

  Future<Map<String, dynamic>> uploadAttachment(
      int? fid, String? authCode, String filePath);

  Future<String?> checkCreateTopic(int fid);

  Future<String> createTopic(int? fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck);

  Future<String> createReply(int? tid, int? fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck);

  Future<ToggleLikeReaction> likeReply(int? tid, int? pid);

  Future<ToggleLikeReaction> dislikeReply(int? tid, int? pid);

  Future<TopicListData> searchTopic(
      String keyword, int? fid, bool content, int? page);

  Future<int> insertTopicHistory(TopicHistory history);

  Future<List<TopicHistory>> getTopicHistories(int limit, int offset);

  Future deleteTopicHistoryById(int id);

  Future<int> deleteAllTopicHistory();
}

class TopicDataRepository implements TopicRepository {
  static const _RESULT_START_TAG = "<span style='color:#aaa'>&gt;</span>";
  static const _RESULT_END_TAG = "<br/>";

  TopicDataRepository(this.database);

  final Database database;

  StoreRef<int, dynamic> get _store {
    if (_lateInitStore == null) {
      _lateInitStore = intMapStoreFactory.store('topic_histories');
    }
    return _lateInitStore!;
  }

  StoreRef<int, dynamic>? _lateInitStore;

  @override
  Future<TopicListData> getTopicList(int fid, int page,
      {bool recommend = false, int? type = 0}) async {
    try {
      final fidParam = type == 1 ? "stid=$fid" : "fid=$fid";
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("thread.php?__output=8&$fidParam&page=$page"
              "${recommend ? "&recommend=1&order_by=postdatedesc" : ""}");
      return TopicListData.fromJson(response.data!, page);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<TopicListData> getFavouriteTopicList(int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("thread.php?favor=1&__output=8&page=$page");
      return TopicListData.fromJson(response.data!, page);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> addFavouriteTopic(int? tid) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.post(
          "nuke.php?__lib=topic_favor&__output=8&__act=topic_favor&action=add&tid=$tid");
      return response.data!['0'];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> deleteFavouriteTopic(int? tid, int? page) async {
    try {
      final postData = "__output=8"
          "&__lib=topic_favor"
          "&__act=topic_favor"
          "&action=del"
          "&page=$page"
          "&tidarray=$tid";
      final options = Options()
        ..contentType = "application/x-www-form-urlencoded";
      Response<Map<String, dynamic>> response =
          await Data().dio.post("nuke.php", data: postData, options: options);
      return response.data!['0'];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<TopicDetailData> getTopicDetail(int tid, int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("read.php?__output=8&tid=$tid&page=$page");
      return TopicDetailData.fromJson(response.data!);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<TopicDetailData> getTopicReply(int? pid) async {
    try {
      Response<Map<String, dynamic>> response =
          await Data().dio.get("read.php?__output=8&pid=$pid");
      return TopicDetailData.fromJson(response.data!);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<TopicTag>> getTopicTagList(int fid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?fid=$fid&__output=8&__lib=topic_key&__act=get");
      List<TopicTag> list = [];
      Map<String, dynamic> tagMap = response.data!["0"];
      tagMap.forEach((k, v) {
        list.add(TopicTag(id: int.tryParse(k)!, content: v["0"]));
      });
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> getAuthCode(int? fid, int? tid, String action) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
            "post.php?__output=8&fid=$fid&tid=$tid&action=$action",
          );
      return response.data!["auth"];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> uploadAttachment(
      int? fid, String? authCode, String filePath) async {
    try {
      final fileName = basename(filePath);
      final formData = FormData.fromMap({
        "attachment_file1":
            MultipartFile.fromFile(filePath, filename: fileName),
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
          .post("https://img.nga.178.com:8080/attach.php", data: formData);
      debugPrint(response.toString());
      return response.data!;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> checkCreateTopic(int fid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?fid=$fid&__output=8&lite=js&action=new");
      return response.data!['auth'];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String> createTopic(int? fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck) async {
    final postData = "step=2"
        "&post_content=${codeUtils.urlEncode(content)}"
        "&action=new"
        "&post_subject=${codeUtils.urlEncode(subject)}"
        "&fid=$fid${isAnonymous ? "anony=1" : ""}"
        "${!codeUtils.isStringEmpty(attachments) ? "&attachments=$attachments" : ""}"
        "${!codeUtils.isStringEmpty(attachmentsCheck) ? "&attachments_check=$attachmentsCheck" : ""}";
    try {
      final options = Options()
        ..contentType = "application/x-www-form-urlencoded";
      Response<String> response = await Data().dio.post(
            "post.php",
            data: postData,
            options: options,
          );
      final html = response.data!;
      int start = html.indexOf(_RESULT_START_TAG);
      if (start == -1) return "发帖失败";
      start += _RESULT_START_TAG.length;
      int end = html.indexOf(_RESULT_END_TAG, start);
      if (end < 0) return "发帖失败";
      return html.substring(start, end);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String> createReply(int? tid, int? fid, String subject, String content,
      bool isAnonymous, String attachments, String attachmentsCheck) async {
    final postData = "step=2"
        "&post_content=${codeUtils.urlEncode(content)}"
        "&tid=$tid"
        "&action=reply"
        "&post_subject=${codeUtils.urlEncode(subject)}"
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
      final html = response.data!;
      int start = html.indexOf(_RESULT_START_TAG);
      if (start == -1) return "发帖失败";
      start += _RESULT_START_TAG.length;
      int end = html.indexOf(_RESULT_END_TAG, start);
      if (end < 0) return "发帖失败";
      return html.substring(start, end);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<ToggleLikeReaction> likeReply(int? tid, int? pid) async {
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
      return ToggleLikeReaction.fromJson(response.data!);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<ToggleLikeReaction> dislikeReply(int? tid, int? pid) async {
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
      return ToggleLikeReaction.fromJson(response.data!);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<TopicListData> searchTopic(
      String keyword, int? fid, bool content, int? page) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "thread.php?${fid == null ? "" : "fid=$fid&"}key=$keyword&page=$page${content ? "&content=1" : ""}&__output=8");
      return TopicListData.fromJson(response.data!, page);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<int> insertTopicHistory(TopicHistory history) async {
    final finder = Finder(
      limit: 1,
      offset: 0,
      filter: Filter.equals('tid', history.tid),
      sortOrders: [SortOrder('time', false)],
    );
    RecordSnapshot<int, dynamic>? record =
        await _store.query(finder: finder).getSnapshot(database);
    if (record != null) {
      final latest = TopicHistory.fromJson(record.value)..id = record.key;
      final latestDate = DateTime.fromMicrosecondsSinceEpoch(latest.time!);
      final historyDate = DateTime.fromMicrosecondsSinceEpoch(history.time!);
      if (latestDate.difference(historyDate).inDays == 0) {
        history.id = latest.id;
        return _store.update(database, history.toJson(), finder: finder);
      }
    }
    return _store.add(database, history.toJson());
  }

  @override
  Future<List<TopicHistory>> getTopicHistories(int limit, int offset) async {
    List<RecordSnapshot<int, dynamic>> results = await _store.find(database,
        finder: Finder(
          limit: limit,
          offset: offset,
          sortOrders: [SortOrder('time', false)],
        ));
    return results
        .map((map) => TopicHistory.fromJson(map.value)..id = map.key)
        .toList();
  }

  @override
  Future deleteTopicHistoryById(int id) async {
    return _store.record(id).delete(database);
  }

  @override
  Future<int> deleteAllTopicHistory() {
    return _store.delete(database);
  }
}
