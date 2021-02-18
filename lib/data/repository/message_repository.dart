import 'package:dio/dio.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';

import '../data.dart';

abstract class MessageRepository {
  Future<ConversationListData> getConversationList(int page);

  Future<MessageListData> getMessageList(int mid, int page);

  Future<void> sendMessage(
      int mid, List<String> sendTo, String subject, String content);
}

class MessageDataRepository extends MessageRepository {
  @override
  Future<ConversationListData> getConversationList(int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=message&__output=8&act=list&__act=message&page=$page");
      return ConversationListData.fromJson(response.data['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<MessageListData> getMessageList(int mid, int page) async {
    try {
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=message&__output=8&act=read&__act=message&mid=$mid&page=$page");
      return MessageListData.fromJson(response.data['0']);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(
      int mid, List<String> sendTo, String subject, String content) async {
    try {
      final isNew = mid == null || mid == 0;
      final sendToValue = sendTo != null && sendTo.isNotEmpty
          ? sendTo.reduce((s, e) => "$s,$e")
          : "";
      final postData = "__lib=message&__act=message"
          "&__output=8"
          "&act=${isNew ? 'new' : 'reply'}"
          "&to=${await AndroidGbk.urlDecode(sendToValue)}"
          "&mid=${mid == null ? 0 : mid}"
          "&subject=${await AndroidGbk.urlEncode(subject)}"
          "&content=${await AndroidGbk.urlEncode(content)}";
      final options = Options()
        ..contentType = "application/x-www-form-urlencoded";
      Response<Map<String, dynamic>> response =
          await Data().dio.post("nuke.php", data: postData, options: options);
      return null;
    } catch (err) {
      rethrow;
    }
  }
}
