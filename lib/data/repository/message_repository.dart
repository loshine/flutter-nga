import 'package:dio/dio.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

abstract class MessageRepository {
  Future<ConversationListData> getConversationList(int page);

  Future<MessageListData> getMessageList(int? mid, int page);

  /// 发起新对话（[mid] 为空或 0）或回复对话。[isolate] 仅对新对话有效：
  /// 参与者只能看到自己的回复。
  Future<void> sendMessage(
    int? mid,
    List<String> sendTo,
    String subject,
    String content, {
    bool isolate = false,
  });

  /// 邀请用户加入对话，[users] 为 UID 或用户名。返回服务端提示。
  Future<String?> inviteToConversation(int mid, List<String> users);

  /// 退出对话（[uid] 为自己），或由发起人把 [uid] 移出对话。返回服务端提示。
  Future<String?> leaveConversation(int mid, int uid);

  /// 屏蔽列表：被屏蔽的用户无法与你对话。
  Future<List<MessageParticipant>> getMessageBlockList();

  /// 屏蔽用户，[users] 为 UID 或用户名。返回服务端提示。
  Future<String?> addMessageBlock(List<String> users);

  /// 解除屏蔽。返回服务端提示。
  Future<String?> removeMessageBlock(int uid);

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
    String content, {
    bool isolate = false,
  }) async {
    final isNew = mid == null || mid == 0;
    await _postMessage(isNew ? 'new' : 'reply', {
      if (isNew) 'to': _joinUsers(sendTo),
      'mid': '${mid ?? 0}',
      'subject': subject,
      'content': content,
      if (isNew && isolate) 'isolate': '1',
    });
  }

  @override
  Future<String?> inviteToConversation(int mid, List<String> users) {
    return _postMessage('add', {'mid': '$mid', 'to': _joinUsers(users)});
  }

  @override
  Future<String?> leaveConversation(int mid, int uid) {
    return _postMessage('leave_topic', {'mid': '$mid', 'luid': '$uid'});
  }

  @override
  Future<List<MessageParticipant>> getMessageBlockList() async {
    final response = await _dio.get<Map<String, dynamic>>(
      "nuke.php?__lib=message&__act=message&act=list_block&__output=8",
    );
    final data = response.data?['0'];
    // 没有屏蔽用户时服务端返回提示字符串
    if (data is! Map) return const [];
    final result = <MessageParticipant>[];
    for (final entry in data.entries) {
      if (int.tryParse('${entry.key}') == null) continue;
      final value = entry.value;
      if (value is! Map) continue;
      final uid = int.tryParse('${value['uid']}');
      if (uid == null) continue;
      result.add(MessageParticipant(uid, '${value['username'] ?? 'UID:$uid'}'));
    }
    return result;
  }

  @override
  Future<String?> addMessageBlock(List<String> users) {
    return _postMessage('add_block', {'buids': _joinUsers(users)});
  }

  @override
  Future<String?> removeMessageBlock(int uid) {
    return _postMessage('del_block', {'buids': '$uid'});
  }

  String _joinUsers(List<String> users) =>
      users.map((e) => e.trim()).where((e) => e.isNotEmpty).join(',');

  /// 提交 `__lib=message` 的写操作，参数按 GBK 编码；返回服务端的提示文本。
  Future<String?> _postMessage(String act, Map<String, String> params) async {
    final body = StringBuffer(
      "__lib=message&__act=message&__output=8&act=$act",
    );
    params.forEach((key, value) {
      body.write('&$key=${code_utils.urlEncode(value)}');
    });
    final response = await _dio.post<dynamic>(
      "nuke.php",
      data: body.toString(),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data;
    if (data is Map) {
      final first = data['0'];
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
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
