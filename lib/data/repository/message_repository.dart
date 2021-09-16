import 'package:dio/dio.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;

import '../data.dart';

abstract class MessageRepository {
  Future<ConversationListData> getConversationList(int page);

  Future<MessageListData> getMessageList(int? mid, int page);

  Future<void> sendMessage(
      int? mid, List<String> sendTo, String subject, String content);

  Future<NotificationInfo> getNotificationInfo();

  Future<NotificationInfoListData> getNotificationList();
}

class MessageDataRepository extends MessageRepository {
  @override
  Future<ConversationListData> getConversationList(int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=message&__output=8&act=list&__act=message&page=$page");
      return ConversationListData.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<MessageListData> getMessageList(int? mid, int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=message&__output=8&act=read&__act=message&mid=$mid&page=$page");
      return MessageListData.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(
      int? mid, List<String> sendTo, String subject, String content) async {
    try {
      final isNew = mid == null || mid == 0;
      final sendToValue =
          sendTo.isNotEmpty ? sendTo.reduce((s, e) => "$s,$e") : "";
      final postData = "__lib=message&__act=message"
          "&__output=8"
          "&act=${isNew ? 'new' : 'reply'}"
          "&to=${codeUtils.urlDecode(sendToValue)}"
          "&mid=${mid == null ? 0 : mid}"
          "&subject=${codeUtils.urlEncode(subject)}"
          "&content=${codeUtils.urlEncode(content)}";
      final options = Options()
        ..contentType = Headers.formUrlEncodedContentType;
      Response<Map<String, dynamic>> response =
          await Data().dio.post("nuke.php", data: postData, options: options);
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<NotificationInfo> getNotificationInfo() async {
    try {
      Response<Map<String, dynamic>> response =
          await Data().dio.get("nuke.php?__output=8&__lib=noti&__act=if");
      return NotificationInfo.fromJson(response.data!['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<NotificationInfoListData> getNotificationList() async {
    try {
      Response<Map<String, dynamic>> response =
          await Data().dio.get("nuke.php?__output=8&__lib=noti&__act=get_all");
      final data = response.data!['0'];
      if (data == "") {
        return NotificationInfoListData.fromJson({});
      } else {
        return NotificationInfoListData.fromJson(response.data!['0']);
      }
    } catch (err) {
      rethrow;
    }
  }
}
