import 'package:dio/dio.dart';
import 'package:flutter_nga/data/entity/message.dart';

import '../data.dart';

abstract class MessageRepository {
  Future<ConversationListData> getConversationList(int page);
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

  // nuke.php?__lib=message&__output=8&act=read&__act=message&mid=2330248&page=1
}
