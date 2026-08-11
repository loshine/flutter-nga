import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/route.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    _subscription = Login.cookieStream.listen((event) {
      _processCookieJson(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _selectAction,
            itemBuilder: (BuildContext context) {
              return ["原生登录", "导入 Cookies"].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
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

  void _selectAction(String value) {
    if ("原生登录" == value) {
      Login.startLogin();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return ImportCookiesDialog(cookiesCallback: _processCookiesString);
        },
      );
    }
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
