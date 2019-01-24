import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_web/flutter_native_web.dart';
import 'package:flutter_nga/utils/constant.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebController _controller;

  _saveCookies(BuildContext context) async {
//    var cookies = await flutterWebviewPlugin.getCookies();
    try {
//      var user = await Data().userRepository.saveLoginCookies(cookies);
    } catch (e) {
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  _refreshBrowser() {
    _controller.loadUrl(LOGIN_URL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登陆"),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () => _refreshBrowser(),
          ),
          IconButton(
            icon: Icon(
              CommunityMaterialIcons.cookie,
              size: 24,
              color: Colors.white,
            ),
            onPressed: () => _saveCookies(context),
          )
        ],
      ),
      body: FlutterNativeWeb(onWebCreated: (controller) {
        if (_controller == null) {
          _controller = controller;
        }
        _refreshBrowser();
      }),
    );
  }
}
