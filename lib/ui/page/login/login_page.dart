import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            Map map = json.decode(cookiesJson);
            Data()
                .userRepository
                .saveLogin(map['uid'].toString(), map['token'], map['username'])
                .whenComplete(() {
              Fluttertoast.showToast(msg: "登录成功");
              Routes.pop(context);
            });
          }
        },
      ),
    );
  }
}
