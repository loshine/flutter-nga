import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    Fluttertoast.showToast(msg: "点击右上角按钮可切换原生 WebView 登录");
    AndroidLogin.cookieStream.listen((event) {
      _processCookieJson(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    AndroidLogin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
        actions: [
          IconButton(
            icon: Icon(CommunityMaterialIcons.android),
            onPressed: AndroidLogin.startLogin,
          )
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.https(DOMAIN_WITHOUT_HTTPS, "nuke.php", {
          '__lib': 'login',
          '__act': 'account',
          'login': null,
        })),
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
}
