import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/ui/page/account_management/account_management_page.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_page.dart';
import 'package:flutter_nga/ui/page/publish/publish_reply.dart';
import 'package:flutter_nga/ui/page/search/search_page.dart';
import 'package:flutter_nga/ui/page/settings/settings.dart';
import 'package:flutter_nga/ui/page/splash/splash_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_page.dart';
import 'package:flutter_nga/ui/page/user_info/user_info_page.dart';

class Routes {
  static Router router;

  static const String SPLASH = "/";
  static const String HOME = "/home";
  static const String TOPIC_LIST = "/topic_list";
  static const String TOPIC_DETAIL = "/topic_detail";
  static const String TOPIC_PUBLISH = "/topic_publish";
  static const String USER = "/user";
  static const String SETTINGS = "/settings";
  static const String ACCOUNT_MANAGEMENT = "/account_management";
  static const String SEARCH = "/search";
  static const String PHOTO_PREVIEW = "photo_preview";

  /// 初始化路由
  static void configureRoutes(Router r) {
    router = r;

    /// 第一个参数是路由地址，第二个参数是页面跳转和传参，第三个参数是默认的转场动画，可以看上图
    /// 我这边先不设置默认的转场动画，转场动画在下面会讲，可以在另外一个地方设置（可以看NavigatorUtil类）
    router.define(SPLASH, handler: _splashHandler);
    router.define(HOME, handler: _homeHandler);
    router.define(TOPIC_LIST, handler: _topicListHandler);
    router.define(TOPIC_DETAIL, handler: _topicDetailHandler);
    router.define(TOPIC_PUBLISH, handler: _topicPublishHandler);
    router.define(USER, handler: _userHandler);
    router.define(SETTINGS, handler: _settingsHandler);
    router.define(ACCOUNT_MANAGEMENT, handler: _accountManagementHandler);
    router.define(SEARCH, handler: _searchHandler);
    router.define(PHOTO_PREVIEW, handler: _photoPreviewHandler);
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

  static Handler _splashHandler =
      Handler(handlerFunc: (context, params) => SplashPage());
  static Handler _homeHandler =
      Handler(handlerFunc: (context, params) => HomePage());
  static Handler _topicListHandler = Handler(
      handlerFunc: (context, params) => TopicListPage(
            fid: int.tryParse(params["fid"][0]) ?? 0,
            name: params["name"][0],
          ));
  static Handler _topicDetailHandler = Handler(
      handlerFunc: (context, params) => TopicDetailPage(
            int.tryParse(params["tid"][0]) ?? 0,
            int.tryParse(params["fid"][0]) ?? 0,
            subject: params["subject"][0],
          ));
  static Handler _topicPublishHandler = Handler(handlerFunc: (context, params) {
    List<String> tids = params["tid"];
    if (tids == null || tids.isEmpty) {
      return PublishPage(fid: int.tryParse(params["fid"][0]) ?? 0);
    } else {
      return PublishPage(
        tid: int.tryParse(params["tid"][0]) ?? 0,
        fid: int.tryParse(params["fid"][0]) ?? 0,
      );
    }
  });
  static Handler _userHandler = Handler(
      handlerFunc: (context, params) => UserInfoPage(params["name"][0]));
  static Handler _settingsHandler =
      Handler(handlerFunc: (context, params) => SettingsPage());
  static Handler _accountManagementHandler =
      Handler(handlerFunc: (context, params) => AccountManagementPage());
  static Handler _searchHandler =
      Handler(handlerFunc: (context, params) => SearchPage());
  static Handler _photoPreviewHandler = Handler(
      handlerFunc: (context, params) => PhotoPreviewPage(
            url: params["url"][0],
            screenWidth: double.tryParse(params["screenWidth"][0]) ?? 0,
          ));
}
