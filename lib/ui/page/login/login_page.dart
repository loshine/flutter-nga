import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _processCookieJson(String cookiesJson) {
    Map map = json.decode(cookiesJson);
    Data()
        .userRepository
        .saveLogin(map['uid'].toString(), map['token'], map['username'])
        .whenComplete(() {
      AppToast.success("登录成功");
      Routes.pop(context);
    });
  }

  void _showImportCookiesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ImportCookiesDialog(cookiesCallback: _processCookiesString);
      },
    );
  }

  void _processCookiesString(String cookies) {
    Data().userRepository.saveLoginCookies(cookies).whenComplete(() {
      AppToast.success("登录成功");
      Routes.pop(context);
    }).catchError((e, stack) {
      debugPrintStack(stackTrace: stack);
      AppToast.error(e);
      throw e;
    });
  }
}
