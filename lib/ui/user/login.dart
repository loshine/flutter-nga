import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_nga/utils/constant.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

//  var _url = "https://bbs.nga.cn/";
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  _saveCookies(BuildContext context) async {
    var cookies = await flutterWebviewPlugin.getCookies();
    try {
//      var user = await Data().userRepository.saveLoginCookies(cookies);
    } catch (e) {
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  _refreshBrowser() {
    flutterWebviewPlugin.launch(DOMAIN, hidden: false);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: LOGIN_URL,
      clearCookies: false,
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
    );
  }
}
