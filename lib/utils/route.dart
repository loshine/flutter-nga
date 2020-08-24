import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/ui/page/account_management/account_management_page.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/page/login/login_page.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_page.dart';
import 'package:flutter_nga/ui/page/publish/publish_reply.dart';
import 'package:flutter_nga/ui/page/search/search_forum_page.dart';
import 'package:flutter_nga/ui/page/search/search_page.dart';
import 'package:flutter_nga/ui/page/search/search_topic_list_page.dart';
import 'package:flutter_nga/ui/page/settings/settings_page.dart';
import 'package:flutter_nga/ui/page/splash/splash_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_info_page.dart';
import 'package:flutter_nga/utils/code_utils.dart';

class Routes {
  static Router router;

  static const String SPLASH = "/";
  static const String HOME = "/home";
  static const String LOGIN = "/login";
  static const String FORUM_DETAIL = "/forum_detail";
  static const String TOPIC_DETAIL = "/topic_detail";
  static const String TOPIC_PUBLISH = "/topic_publish";
  static const String USER = "/user";
  static const String SETTINGS = "/settings";
  static const String ACCOUNT_MANAGEMENT = "/account_management";
  static const String SEARCH = "/search";
  static const String SEARCH_FORUM = "/search_forum";
  static const String SEARCH_TOPIC_LIST = "/search_topic_list";
  static const String PHOTO_PREVIEW = "/photo_preview";

  /// 初始化路由
  static void configureRoutes(Router r) {
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
        fid: int.tryParse(params["fid"][0]),
        name: fluroCnParamsDecode(params["name"][0]),
        type: params["type"] != null ? int.tryParse(params["type"][0]) : 0,
      );
    }));
    router.define(TOPIC_DETAIL,
        handler: Handler(
            handlerFunc: (context, params) => TopicDetailPage(
                  int.tryParse(params["tid"][0]),
                  int.tryParse(params["fid"][0]),
                  subject: fluroCnParamsDecode(params["subject"][0]),
                )));
    router.define(TOPIC_PUBLISH,
        handler: Handler(handlerFunc: (context, params) {
      final List<String> tidParams = params["tid"];
      if (tidParams == null || tidParams.isEmpty) {
        return PublishPage(fid: int.tryParse(params["fid"][0]));
      } else {
        return PublishPage(
          tid: int.tryParse(params["tid"][0]),
          fid: int.tryParse(params["fid"][0]),
        );
      }
    }));
    router.define(USER, handler: Handler(handlerFunc: (context, params) {
      if (params["uid"] != null && params["uid"].isNotEmpty) {
        return UserInfoPage(uid: params["uid"][0]);
      } else {
        return UserInfoPage(username: fluroCnParamsDecode(params["name"][0]));
      }
    }));
    router.define(SETTINGS,
        handler: Handler(handlerFunc: (context, params) => SettingsPage()));
    router.define(ACCOUNT_MANAGEMENT,
        handler:
            Handler(handlerFunc: (context, params) => AccountManagementPage()));
    router.define(SEARCH, handler: Handler(handlerFunc: (context, params) {
      final List<String> fidParams = params["fid"];
      if (fidParams == null || fidParams.isEmpty) {
        return SearchPage();
      } else {
        return SearchPage(fid: int.tryParse(fidParams[0]));
      }
    }));
    router.define(SEARCH_FORUM,
        handler: Handler(
            handlerFunc: (context, params) =>
                SearchForumPage(fluroCnParamsDecode(params["keyword"][0]))));
    router.define(SEARCH_TOPIC_LIST,
        handler: Handler(handlerFunc: (context, params) {
      final content = params["content"] != null &&
          params["content"].isNotEmpty &&
          params["content"][0] == "1";
      if (params["fid"] == null || params["fid"].isEmpty) {
        return SearchTopicListPage(fluroCnParamsDecode(params["keyword"][0]),
            content: content);
      } else {
        return SearchTopicListPage(
          fluroCnParamsDecode(params["keyword"][0]),
          fid: int.tryParse(params["fid"][0]),
          content: content,
        );
      }
    }));
    router.define(PHOTO_PREVIEW,
        handler: Handler(
            handlerFunc: (context, params) => PhotoPreviewPage(
                  url: fluroCnParamsDecode(params["url"][0]),
                  screenWidth: double.tryParse(params["screenWidth"][0]) ?? 0,
                )));
  }

  /// 代理 Router 类的 navigateTo 方法
  static Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    return router.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transition: transition,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder);
  }

  /// 代理 Router 类的 pop 方法
  static void pop(BuildContext context) {
    router.pop(context);
  }
}
