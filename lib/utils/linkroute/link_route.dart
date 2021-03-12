import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/page/topic_detail/reply_detail_dialog.dart';
import 'package:flutter_nga/utils/route.dart';

/// 超链接对应 Route
abstract class LinkRoute {
  String matchRegExp();

  void handleMatch(BuildContext context, Match match);
}

/// 话题超链接
class TopicLinkRoute extends LinkRoute {
  @override
  void handleMatch(BuildContext context, Match match) {
    Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=${match.group(1)}");
  }

  @override
  String matchRegExp() {
    return "read\\.php\\?tid=(\\d+)?";
  }
}

/// 用户超链接
class UserLinkRoute extends LinkRoute {
  @override
  void handleMatch(BuildContext context, Match match) {
    Routes.navigateTo(context, "${Routes.USER}?uid=${match.group(1)}");
  }

  @override
  String matchRegExp() {
    return "nuke\\.php\\?func=ucp&uid=(\\d+)?";
  }
}

/// 回复超链接
class ReplyLinkRoute extends LinkRoute {
  @override
  void handleMatch(BuildContext context, Match match) {
    showDialog(
        context: context,
        builder: (_) => ReplyDetailDialog(pid: int.tryParse(match.group(1)!)));
  }

  @override
  String matchRegExp() {
    return "read\\.php\\?searchpost=1&pid=(\\d+)?";
  }
}
