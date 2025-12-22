import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    Fluttertoast.showToast(msg: "默认启用原生 WebView 登录");
    _subscription = Login.cookieStream.listen((event) {
      _processCookieJson(event);
    });
    super.initState();
    Login.startLogin();
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
            url: WebUri.uri(Uri.https(DOMAIN_WITHOUT_HTTPS, "nuke.php", {
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
      Fluttertoast.showToast(msg: "登录成功");
      Routes.pop(context);
    });
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

  void _processCookiesString(String cookies) {
    Data().userRepository.saveLoginCookies(cookies).whenComplete(() {
      Fluttertoast.showToast(msg: "登录成功");
      Routes.pop(context);
    }).catchError((e) {
      debugPrintStack(stackTrace: e.stackTrace);
      Fluttertoast.showToast(msg: e.message);
    });
  }
}
