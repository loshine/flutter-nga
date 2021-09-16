import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/ui/page/account_management/account_management_page.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_detail_page.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/page/login/login_page.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_page.dart';
import 'package:flutter_nga/ui/page/publish/publish_page.dart';
import 'package:flutter_nga/ui/page/search/search_forum_page.dart';
import 'package:flutter_nga/ui/page/search/search_page.dart';
import 'package:flutter_nga/ui/page/search/search_topic_list_page.dart';
import 'package:flutter_nga/ui/page/send_message/send_message_page.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/interface_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/settings_page.dart';
import 'package:flutter_nga/ui/page/splash/splash_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_info_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_replies_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_topics_page.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/linkroute/link_route.dart';
import 'package:url_launcher/url_launcher.dart';

class Routes {
  static late FluroRouter router;

  static const String SPLASH = "/";
  static const String HOME = "/home";
  static const String LOGIN = "/login";
  static const String FORUM_DETAIL = "/forum_detail";
  static const String TOPIC_DETAIL = "/topic_detail";
  static const String TOPIC_PUBLISH = "/topic_publish";
  static const String USER = "/user";
  static const String USER_TOPICS = "/user/posts";
  static const String USER_REPLIES = "/user/replies";
  static const String SETTINGS = "/settings";
  static const String INTERFACE_SETTINGS = "/settings/interface";
  static const String BLOCKLIST_SETTINGS = "/settings/blocklist";
  static const String ACCOUNT_MANAGEMENT = "/settings/account_management";
  static const String SEARCH = "/search";
  static const String SEARCH_FORUM = "/search_forum";
  static const String SEARCH_TOPIC_LIST = "/search_topic_list";
  static const String PHOTO_PREVIEW = "/photo_preview";
  static const String CONVERSATION_DETAIL = "/conversation_detail";
  static const String SEND_MESSAGE = "/send_message";

  /// 初始化路由
  static void configureRoutes(FluroRouter r) {
    router = r;

    /// 第一个参数是路由地址，第二个参数是页面跳转和传参，第三个参数是默认的转场动画，可以看上图
    /// 我这边先不设置默认的转场动画，转场动画在下面会讲，可以在另外一个地方设置（可以看NavigatorUtil类）
    router.define(SPLASH,
        handler: Handler(handlerFunc: (context, params) => SplashPage()));
    router.define(HOME,
        handler: Handler(handlerFunc: (context, params) => HomePage()));
    router.define(LOGIN,
        handler: Handler(handlerFunc: (context, params) => LoginPage()));
    router.define(FORUM_DETAIL,
        handler: Handler(handlerFunc: (context, params) {
      return ForumDetailPage(
        fid: int.tryParse(params["fid"]![0])!,
        name: fluroCnParamsDecode(params["name"]![0]),
        type: params["type"] != null ? int.tryParse(params["type"]![0]) : 0,
      );
    }));
    router.define(TOPIC_DETAIL,
        handler: Handler(
            handlerFunc: (context, params) => TopicDetailPage(
                  int.tryParse(params["tid"]![0]),
                  params["fid"] != null
                      ? int.tryParse(params["fid"]![0])
                      : null,
                  subject: params["subject"] != null
                      ? fluroCnParamsDecode(params["subject"]![0])
                      : null,
                  authorid: params["authorid"] != null
                      ? int.tryParse(params["authorid"]![0])
                      : null,
                )));
    router.define(TOPIC_PUBLISH,
        handler: Handler(handlerFunc: (context, params) {
      final List<String>? tidParams = params["tid"];
      if (tidParams == null || tidParams.isEmpty) {
        return PublishPage(fid: int.tryParse(params["fid"]![0]));
      } else {
        String content = context?.settings?.arguments != null
            ? (context!.settings!.arguments as String)
            : "";
        return PublishPage(
          tid: int.tryParse(params["tid"]![0]),
          fid: int.tryParse(params["fid"]![0]),
          content: content,
        );
      }
    }));
    router.define(USER, handler: Handler(handlerFunc: (context, params) {
      if (params["uid"] != null && params["uid"]!.isNotEmpty) {
        return UserInfoPage(uid: params["uid"]![0]);
      } else {
        return UserInfoPage(username: fluroCnParamsDecode(params["name"]![0]));
      }
    }));
    router.define(USER_TOPICS, handler: Handler(handlerFunc: (context, params) {
      return UserTopicsPage(
        uid: int.tryParse(params['uid']![0]) ?? 0,
        username: fluroCnParamsDecode(params['username']![0]),
      );
    }));
    router.define(USER_REPLIES,
        handler: Handler(handlerFunc: (context, params) {
      return UserRepliesPage(
        uid: int.tryParse(params['uid']![0]) ?? 0,
        username: fluroCnParamsDecode(params['username']![0]),
      );
    }));
    router.define(SETTINGS,
        handler: Handler(handlerFunc: (context, params) => SettingsPage()));
    router.define(INTERFACE_SETTINGS,
        handler:
            Handler(handlerFunc: (context, params) => InterfaceSettingsPage()));
    router.define(BLOCKLIST_SETTINGS,
        handler:
            Handler(handlerFunc: (context, params) => BlocklistSettingsPage()));
    router.define(ACCOUNT_MANAGEMENT,
        handler:
            Handler(handlerFunc: (context, params) => AccountManagementPage()));
    router.define(
      SEARCH,
      handler: Handler(
        handlerFunc: (context, params) {
          final List<String>? fidParams = params["fid"];
          if (fidParams == null || fidParams.isEmpty) {
            return SearchPage();
          } else {
            return SearchPage(fid: int.tryParse(fidParams[0]));
          }
        },
      ),
    );
    router.define(
      SEARCH_FORUM,
      handler: Handler(
        handlerFunc: (context, params) =>
            SearchForumPage(fluroCnParamsDecode(params["keyword"]![0])),
      ),
    );
    router.define(
      SEARCH_TOPIC_LIST,
      handler: Handler(
        handlerFunc: (context, params) {
          final content = params["content"] != null &&
              params["content"]!.isNotEmpty &&
              params["content"]![0] == "1";
          if (params["fid"] == null || params["fid"]!.isEmpty) {
            return SearchTopicListPage(
                fluroCnParamsDecode(params["keyword"]![0]),
                content: content);
          } else {
            return SearchTopicListPage(
              fluroCnParamsDecode(params["keyword"]![0]),
              fid: int.tryParse(params["fid"]![0]),
              content: content,
            );
          }
        },
      ),
    );
    router.define(
      PHOTO_PREVIEW,
      handler: Handler(
        handlerFunc: (context, params) => PhotoPreviewPage(
          url: fluroCnParamsDecode(params["url"]![0]),
          screenWidth: double.tryParse(params["screenWidth"]![0]) ?? 0,
        ),
      ),
    );
    router.define(
      CONVERSATION_DETAIL,
      handler: Handler(
        handlerFunc: (context, params) => ConversationDetailPage(
          mid: int.tryParse(params["mid"]![0]),
        ),
      ),
    );
    router.define(
      SEND_MESSAGE,
      handler: Handler(
        handlerFunc: (context, params) => SendMessagePage(
          mid: int.tryParse(params["mid"]![0]),
        ),
      ),
    );
  }

  /// 代理 Router 类的 navigateTo 方法
  static Future navigateTo(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    bool maintainState = true,
    bool rootNavigator = false,
    TransitionType transition = TransitionType.native,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder? transitionBuilder,
    RouteSettings? routeSettings,
  }) {
    return router.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      maintainState: maintainState,
      rootNavigator: rootNavigator,
      transition: transition,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      routeSettings: routeSettings,
    );
  }

  /// 代理 Router 类的 pop 方法
  static void pop(BuildContext context) {
    router.pop(context);
  }

  /// 处理 html 控件中超链接点击事件
  static void onLinkTap(BuildContext context, String? link) {
    debugPrint("User tap link: $link");
    var handled = false;
    for (LinkRoute linkRoute in _linkRoutes) {
      final matches = RegExp(linkRoute.matchRegExp()).allMatches(link ?? "");
      if (matches.isEmpty) continue;
      matches.forEach((match) => linkRoute.handleMatch(context, match));
      handled = true;
    }
    if (!handled) {
      launch(link ?? "");
    }
  }

  /// 提前定义好的超链接对应的路由
  static final _linkRoutes = [
    TopicLinkRoute(),
    UserLinkRoute(),
    ReplyLinkRoute(),
  ];
}
