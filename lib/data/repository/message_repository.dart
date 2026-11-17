import 'package:dio/dio.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

abstract class MessageRepository {
  Future<ConversationListData> getConversationList(int page);

  Future<MessageListData> getMessageList(int? mid, int page);

  Future<void> sendMessage(
    int? mid,
    List<String> sendTo,
    String subject,
    String content,
  );

  Future<NotificationInfo> getNotificationInfo();

  Future<NotificationInfoListData> getNotificationList();

  /// 清空服务端的提醒信箱。
  Future<void> clearNotifications();

  /// 不再提示指定主题（[pid] 为 0）或回复的回复与评论。
  Future<void> setNotificationNoHint(int tid, int pid);
}

class MessageDataRepository extends MessageRepository {
  MessageDataRepository(this._dio);

  final Dio _dio;

  @override
  Future<ConversationListData> getConversationList(int page) async {
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
        "nuke.php?__lib=message&__output=8&act=list&__act=message&page=$page",
      );
      return ConversationListData.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<MessageListData> getMessageList(int? mid, int page) async {
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
        "nuke.php?__lib=message&__output=8&act=read&__act=message&mid=$mid&page=$page",
      );
      return MessageListData.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(
    int? mid,
    List<String> sendTo,
    String subject,
    String content,
  ) async {
    try {
      final isNew = mid == null || mid == 0;
      final sendToValue = sendTo.isNotEmpty
          ? sendTo.reduce((s, e) => "$s,$e")
          : "";
      final postData =
          "__lib=message&__act=message"
          "&__output=8"
          "&act=${isNew ? 'new' : 'reply'}"
          "&to=${code_utils.urlDecode(sendToValue)}"
          "&mid=${mid ?? 0}"
          "&subject=${code_utils.urlEncode(subject)}"
          "&content=${code_utils.urlEncode(content)}";
      final options = Options()
        ..contentType = Headers.formUrlEncodedContentType;
      await _dio.post("nuke.php", data: postData, options: options);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<NotificationInfo> getNotificationInfo() async {
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
        "nuke.php?__output=8&__lib=noti&__act=if",
      );
      return NotificationInfo.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<NotificationInfoListData> getNotificationList() async {
    try {
      Response<Map<String, dynamic>> response = await _dio.get(
        // time_limit=1 取全部提醒（网页版打开「信箱」时的参数），
        // 否则只返回上次获取之后的新提醒。
        "nuke.php?__output=8&__lib=noti&__act=get_all&time_limit=1",
      );
      final data = response.data?['0'];
      if (data is Map<String, dynamic>) {
        return NotificationInfoListData.fromJson(data);
      }
      return const NotificationInfoListData();
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> clearNotifications() async {
    await _dio.post(
      "nuke.php",
      data: "__lib=noti&__act=del&__output=8",
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }

  @override
  Future<void> setNotificationNoHint(int tid, int pid) async {
    await _dio.post(
      "nuke.php",
      data:
          "__lib=noti&__act=set_post_tag&__output=8"
          "&no_hint=1&tid=$tid&pid=$pid",
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }
}
