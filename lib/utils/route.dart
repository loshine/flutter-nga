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
import 'package:flutter_nga/ui/page/settings/blocklist_keywords_page.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_users_page.dart';
import 'package:flutter_nga/ui/page/settings/interface_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/settings_page.dart';
import 'package:flutter_nga/ui/page/splash/splash_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_info_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_replies_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_topics_page.dart';
import 'package:flutter_nga/utils/linkroute/link_route.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class Routes {
  static late GoRouter router;

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
  static const String BLOCKLIST_USERS = "/settings/blocklist/users";
  static const String BLOCKLIST_KEYWORDS = "/settings/blocklist/keywords";
  static const String ACCOUNT_MANAGEMENT = "/settings/account_management";
  static const String SEARCH = "/search";
  static const String SEARCH_FORUM = "/search_forum";
  static const String SEARCH_TOPIC_LIST = "/search_topic_list";
  static const String PHOTO_PREVIEW = "/photo_preview";
  static const String CONVERSATION_DETAIL = "/conversation_detail";
  static const String SEND_MESSAGE = "/send_message";

  /// 初始化路由
  static void configureRoutes(GoRouter r) {
    router = r;
  }

  /// 页面跳转（支持查询参数）
  static Future navigateTo(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    final uri = Uri.parse(path);
    final mergedQueryParams = {
      ...uri.queryParameters,
      if (queryParams != null) ...queryParams,
    };
    final newUri = uri.replace(queryParameters: mergedQueryParams);

    if (clearStack) {
      context.pushReplacement(newUri.toString(), extra: extra);
      return Future.value();
    } else if (replace) {
      context.replace(newUri.toString(), extra: extra);
      return Future.value();
    } else {
      return context.push(newUri.toString(), extra: extra);
    }
  }

  /// 带参数的页面跳转
  static Future navigateToWithParams(
    BuildContext context,
    String path,
    Map<String, String> params, {
    bool replace = false,
    bool clearStack = false,
    Object? extra,
  }) {
    return navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      queryParams: params,
      extra: extra,
    );
  }

  /// 简单的页面跳转（无参数）
  static Future push(BuildContext context, String path, {Object? extra}) {
    return context.push(path, extra: extra);
  }

  /// 替换当前页面
  static Future replace(BuildContext context, String path, {Object? extra}) {
    context.replace(path, extra: extra);
    return Future.value();
  }

  /// 返回上一页
  static void pop(BuildContext context) {
    context.pop();
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
      launchUrl(Uri.parse(link ?? ""));
    }
  }

  /// 提前定义好的超链接对应的路由
  static final _linkRoutes = [
    TopicLinkRoute(),
    UserLinkRoute(),
    ReplyLinkRoute(),
  ];
}

/// 构建所有路由配置
List<GoRoute> buildRoutes() {
  return [
    GoRoute(
      path: Routes.SPLASH,
      name: Routes.SPLASH,
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      path: Routes.HOME,
      name: Routes.HOME,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: Routes.LOGIN,
      name: Routes.LOGIN,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: Routes.FORUM_DETAIL,
      name: Routes.FORUM_DETAIL,
      builder: (context, state) => ForumDetailPage(
        fid: int.tryParse(state.uri.queryParameters["fid"] ?? "") ?? 0,
        name: state.uri.queryParameters["name"] ?? "",
        type: int.tryParse(state.uri.queryParameters["type"] ?? "") ?? 0,
      ),
    ),
    GoRoute(
      path: Routes.TOPIC_DETAIL,
      name: Routes.TOPIC_DETAIL,
      builder: (context, state) => TopicDetailPage(
        int.tryParse(state.uri.queryParameters["tid"] ?? ""),
        int.tryParse(state.uri.queryParameters["fid"] ?? ""),
        subject: state.uri.queryParameters["subject"],
        authorid: int.tryParse(state.uri.queryParameters["authorid"] ?? ""),
      ),
    ),
    GoRoute(
      path: Routes.TOPIC_PUBLISH,
      name: Routes.TOPIC_PUBLISH,
      builder: (context, state) {
        final tid = state.uri.queryParameters["tid"];
        final fid = state.uri.queryParameters["fid"];
        final content = state.extra as String? ?? "";
        if (tid != null && tid.isNotEmpty) {
          return PublishPage(
            tid: int.tryParse(tid) ?? 0,
            fid: int.tryParse(fid ?? "") ?? 0,
            content: content,
          );
        } else {
          return PublishPage(fid: int.tryParse(fid ?? "") ?? 0);
        }
      },
    ),
    GoRoute(
      path: Routes.USER,
      name: Routes.USER,
      builder: (context, state) {
        final uid = state.uri.queryParameters["uid"];
        final name = state.uri.queryParameters["name"];
        if (uid != null && uid.isNotEmpty) {
          return UserInfoPage(uid: uid);
        } else {
          return UserInfoPage(username: name ?? "");
        }
      },
    ),
    GoRoute(
      path: Routes.USER_TOPICS,
      name: Routes.USER_TOPICS,
      builder: (context, state) => UserTopicsPage(
        uid: int.tryParse(state.uri.queryParameters["uid"] ?? "") ?? 0,
        username: state.uri.queryParameters["username"] ?? "",
      ),
    ),
    GoRoute(
      path: Routes.USER_REPLIES,
      name: Routes.USER_REPLIES,
      builder: (context, state) => UserRepliesPage(
        uid: int.tryParse(state.uri.queryParameters["uid"] ?? "") ?? 0,
        username: state.uri.queryParameters["username"] ?? "",
      ),
    ),
    GoRoute(
      path: Routes.SETTINGS,
      name: Routes.SETTINGS,
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: Routes.INTERFACE_SETTINGS,
      name: Routes.INTERFACE_SETTINGS,
      builder: (context, state) => InterfaceSettingsPage(),
    ),
    GoRoute(
      path: Routes.BLOCKLIST_SETTINGS,
      name: Routes.BLOCKLIST_SETTINGS,
      builder: (context, state) => BlocklistSettingsPage(),
    ),
    GoRoute(
      path: Routes.BLOCKLIST_USERS,
      name: Routes.BLOCKLIST_USERS,
      builder: (context, state) => BlocklistUsersPage(),
    ),
    GoRoute(
      path: Routes.BLOCKLIST_KEYWORDS,
      name: Routes.BLOCKLIST_KEYWORDS,
      builder: (context, state) => BlocklistKeywordsPage(),
    ),
    GoRoute(
      path: Routes.ACCOUNT_MANAGEMENT,
      name: Routes.ACCOUNT_MANAGEMENT,
      builder: (context, state) => AccountManagementPage(),
    ),
    GoRoute(
      path: Routes.SEARCH,
      name: Routes.SEARCH,
      builder: (context, state) {
        final fid = state.uri.queryParameters["fid"];
        if (fid != null && fid.isNotEmpty) {
          return SearchPage(fid: int.tryParse(fid) ?? 0);
        } else {
          return SearchPage();
        }
      },
    ),
    GoRoute(
      path: Routes.SEARCH_FORUM,
      name: Routes.SEARCH_FORUM,
      builder: (context, state) => SearchForumPage(
        state.uri.queryParameters["keyword"] ?? "",
      ),
    ),
    GoRoute(
      path: Routes.SEARCH_TOPIC_LIST,
      name: Routes.SEARCH_TOPIC_LIST,
      builder: (context, state) {
        final content = state.uri.queryParameters["content"] == "1";
        final fid = state.uri.queryParameters["fid"];
        if (fid != null && fid.isNotEmpty) {
          return SearchTopicListPage(
            state.uri.queryParameters["keyword"] ?? "",
            fid: int.tryParse(fid) ?? 0,
            content: content,
          );
        } else {
          return SearchTopicListPage(
            state.uri.queryParameters["keyword"] ?? "",
            content: content,
          );
        }
      },
    ),
    GoRoute(
      path: Routes.PHOTO_PREVIEW,
      name: Routes.PHOTO_PREVIEW,
      builder: (context, state) => PhotoPreviewPage(
        url: state.uri.queryParameters["url"] ?? "",
        screenWidth:
            double.tryParse(state.uri.queryParameters["screenWidth"] ?? "") ??
                0,
      ),
    ),
    GoRoute(
      path: Routes.CONVERSATION_DETAIL,
      name: Routes.CONVERSATION_DETAIL,
      builder: (context, state) => ConversationDetailPage(
        mid: int.tryParse(state.uri.queryParameters["mid"] ?? "") ?? 0,
      ),
    ),
    GoRoute(
      path: Routes.SEND_MESSAGE,
      name: Routes.SEND_MESSAGE,
      builder: (context, state) => SendMessagePage(
        mid: int.tryParse(state.uri.queryParameters["mid"] ?? "") ?? 0,
      ),
    ),
  ];
}
