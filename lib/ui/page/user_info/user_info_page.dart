import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/user_info_store.dart';
import 'package:flutter_nga/ui/widget/info_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserInfoPage extends StatefulWidget {
  final String username;
  final String uid;

  const UserInfoPage({this.username, this.uid, Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserInfoStore _store = UserInfoStore();

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      _store.loadByUid(widget.uid).catchError((err) {
        if (err is DioError) {
          Fluttertoast.showToast(
            msg: err.message,
            gravity: ToastGravity.CENTER,
          );
        } else if (err is Error) {
          Fluttertoast.showToast(
            msg: err.toString(),
            gravity: ToastGravity.CENTER,
          );
        }
      });
    } else if (widget.username != null) {
      _store.loadByName(widget.username).catchError((err) {
        if (err is DioError) {
          Fluttertoast.showToast(
            msg: err.message,
            gravity: ToastGravity.CENTER,
          );
        } else if (err is Error) {
          Fluttertoast.showToast(
            msg: err.toString(),
            gravity: ToastGravity.CENTER,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    _store.state.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Container(
                      child: codeUtils.isStringEmpty(_store.state.avatar)
                          ? SizedBox.expand(child: Text(""))
                          : CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: _store.state.avatar,
                              placeholder: (context, url) =>
                                  Image.asset('images/default_forum_icon.png'),
                              errorWidget: (context, url, err) =>
                                  Image.asset('images/default_forum_icon.png'),
                            ),
                      foregroundDecoration:
                          BoxDecoration(color: Colors.black38)),
                ),
              ),
              SliverList(
                delegate:
                    SliverChildListDelegate(_getBodyWidgets(_store.state)),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _getAdminForumWidgets(UserInfoState userInfo) {
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 管理权限 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.colorTextSubTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Text(
        "在以下版面担任版主",
        style: TextStyle(color: Palette.colorTextSecondary),
      )
    ];

    if (userInfo.moderatorForums.isNotEmpty) {
      widgets.addAll(userInfo.moderatorForums.entries.map(
        (entry) => Builder(
            builder: (context) => GestureDetector(
                  onTap: () => Routes.navigateTo(context,
                      "${Routes.TOPIC_LIST}?fid=${entry.key}&name=${codeUtils.fluroCnParamsEncode(entry.value)}"),
                  child: Text(
                    "[${entry.value}]",
                    style: TextStyle(color: Palette.colorTextSubTitle),
                  ),
                )),
      ));
    } else {
      widgets.add(Text("无管理版块"));
    }
    return widgets;
  }

  List<Widget> _getReputationWidgets(UserInfoState userInfo) {
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 声望 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.colorTextSubTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Text(
        "表示与 论坛/某版面/某用户 的关系",
        style: TextStyle(color: Palette.colorTextSecondary),
      )
    ];
    widgets.addAll(userInfo.reputationMap.entries.map((entry) => InfoWidget(
          title: "${entry.key}: ",
          subTitle: entry.value,
        )));
    return widgets;
  }

  List<Widget> _getBodyWidgets(UserInfoState userInfo) {
    List<Widget> basicWidgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 基础信息 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.colorTextSubTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    basicWidgets.addAll(userInfo.basicInfoMap.entries.map(
        (entry) => InfoWidget(title: "${entry.key}: ", subTitle: entry.value)));

    List<Widget> widgets = [
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Color(0xFFF5E8CB),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: basicWidgets,
            ),
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Color(0xFFF5E8CB),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    ":: 签名 ::",
                    style: TextStyle(
                      fontSize: Dimen.subheading,
                      color: Palette.colorTextSubTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Html(data: userInfo.signature)
              ],
            ),
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Color(0xFFF5E8CB),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getAdminForumWidgets(userInfo),
            ),
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Color(0xFFF5E8CB),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getReputationWidgets(userInfo),
            ),
          ),
        ),
      ),
    ];

    if (userInfo.personalForum.isNotEmpty) {
      widgets.add(
        Card(
          margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
          color: Color(0xFFF5E8CB),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      ":: 个人版面 ::",
                      style: TextStyle(
                        fontSize: Dimen.subheading,
                        color: Palette.colorTextSubTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "个人版面是由用户自己管理的版面",
                    style: TextStyle(color: Palette.colorTextSecondary),
                  ),
                  Builder(builder: (context) {
                    final entry = userInfo.personalForum.entries.toList()[0];
                    return GestureDetector(
                      onTap: () => Routes.navigateTo(context,
                          "${Routes.TOPIC_LIST}?fid=${entry.key}&name=${codeUtils.fluroCnParamsEncode(entry.value)}"),
                      child: Text(
                        "[${entry.value}]",
                        style: TextStyle(color: Palette.colorTextSubTitle),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}
