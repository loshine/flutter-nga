import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/route.dart';

/// NGA 登录页未声明移动端 viewport，WebView 会按桌面宽度排版后整体缩小，
/// 注入 viewport 让页面按设备宽度排版以撑满屏幕
const _fitViewportScript = '''
(function() {
  const content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no';
  let viewport = document.querySelector('meta[name="viewport"]');
  if (viewport) {
    viewport.setAttribute('content', content);
  } else {
    viewport = document.createElement('meta');
    viewport.name = 'viewport';
    viewport.content = content;
    document.head.appendChild(viewport);
  }
})();
''';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
        actions: <Widget>[
          IconButton(
            tooltip: "导入 Cookies",
            onPressed: _showImportCookiesDialog,
            icon: const Icon(Icons.cookie_outlined),
          )
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.https(Data().domain, "nuke.php", {
          '__lib': 'login',
          '__act': 'account',
          'login': null,
        }))),
        onLoadStop: (InAppWebViewController controller, WebUri? url) async {
          if (url?.queryParameters['__lib'] == 'login') {
            await controller.evaluateJavascript(source: _fitViewportScript);
          }
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
          if (consoleMessage.message.startsWith("loginSuccess :")) {
            final cookiesJson =
                consoleMessage.message.substring("loginSuccess : ".length);
            _processCookieJson(cookiesJson);
          }
        },
      ),
    );
  }

  Future<void> _processCookieJson(String cookiesJson) async {
    try {
      final map = json.decode(cookiesJson) as Map;
      await Data().userRepository.saveLogin(
            map['uid'].toString(),
            map['token'],
            map['username'],
          );
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
      if (mounted) {
        AppToast.success("登录成功");
        Routes.pop(context);
      }
    } catch (error) {
      AppToast.error(error);
    }
  }

  void _showImportCookiesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ImportCookiesDialog(cookiesCallback: _processCookiesString);
      },
    );
  }

  Future<void> _processCookiesString(String cookies) async {
    try {
      await Data().userRepository.saveLoginCookies(cookies);
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
      if (!mounted) return;
      AppToast.success("登录成功");
      Routes.pop(context);
    } catch (error, stack) {
      debugPrintStack(stackTrace: stack);
      AppToast.error(error);
    }
  }
}
