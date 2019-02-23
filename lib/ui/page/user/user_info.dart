import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/bloc/user_info_bloc.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic/topic_list.dart';
import 'package:flutter_nga/ui/widget/info_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UserInfoPage extends StatefulWidget {
  final String username;

  const UserInfoPage(this.username, {Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserInfoBloc _bloc;
  StreamSubscription _subscription;
  final _format = DateFormat('yyyy-MM-dd hh:mm:ss');

  @override
  void initState() {
    super.initState();
    _createBloc();
  }

  @override
  void didUpdateWidget(UserInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeBloc();
    _createBloc();
  }

  @override
  void dispose() {
    _disposeBloc();
    super.dispose();
  }

  void _createBloc() {
    _bloc = UserInfoBloc(widget.username);
    _subscription = _bloc.outErrorMessage.listen(
      (message) => Fluttertoast.showToast(
            msg: message,
            gravity: ToastGravity.CENTER,
          ),
    );
  }

  void _disposeBloc() {
    _subscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserInfo>(
        stream: _bloc.outUserInfo,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    snapshot.data == null ? "" : snapshot.data.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Container(
                      child: snapshot.data == null
                          ? SizedBox.expand()
                          : CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: snapshot.data.avatar,
                              placeholder: (context, url) =>
                                  Image.asset('images/default_forum_icon.png'),
                              errorWidget: (context, url, e) =>
                                  Image.asset('images/default_forum_icon.png'),
                            ),
                      foregroundDecoration:
                          BoxDecoration(color: Colors.black38)),
                ),
              ),
              SliverList(
                delegate:
                    SliverChildListDelegate(_getBodyWidgets(snapshot.data)),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _getAdminForumWidgets(UserInfo userInfo) {
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

    if (userInfo != null &&
        userInfo.adminForums != null &&
        userInfo.adminForums.isNotEmpty) {
      widgets.addAll(userInfo.adminForums.entries.map(
        (entry) => GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TopicListPage(
                        fid: int.parse(entry.key),
                        name: entry.value,
                      ))),
              child: Text(
                CodeUtils.unescapeHtml("[${entry.value}]"),
                style: TextStyle(color: Palette.colorTextSubTitle),
              ),
            ),
      ));
    } else {
      widgets.add(Text("无管理版块"));
    }
    return widgets;
  }

  List<Widget> _getReputationWidgets(UserInfo userInfo) {
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
    widgets.add(InfoWidget(
      title: "威望: ",
      subTitle: "${userInfo == null ? 0 : userInfo.fame / 10}",
    ));
    if (userInfo != null &&
        userInfo.reputation != null &&
        userInfo.reputation.isNotEmpty) {
      widgets.addAll(userInfo.reputation.map((reputation) => InfoWidget(
            title: "${reputation.name}: ",
            subTitle: "${reputation.value}",
          )));
    }
    return widgets;
  }

  List<Widget> _getBodyWidgets(UserInfo userInfo) {
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
              children: [
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
                InfoWidget(
                  title: "用户ID: ",
                  subTitle: userInfo == null ? "N/A" : "${userInfo.uid}",
                ),
                InfoWidget(
                  title: "用户名: ",
                  subTitle: userInfo == null ? "N/A" : "${userInfo.username}",
                ),
                InfoWidget(
                  title: "用户组: ",
                  subTitle: userInfo == null
                      ? "N/A"
                      : "${userInfo.group}(${userInfo.groupId})",
                ),
                InfoWidget(
                  title: "财富: ",
                  subTitle: userInfo == null || userInfo.money == null
                      ? "N/A"
                      : "${userInfo.money ~/ 10000}金 ${(userInfo.money % 10000) ~/ 100}银 ${userInfo.money % 100}铜",
                ),
                InfoWidget(
                  title: "注册日期: ",
                  subTitle: userInfo == null
                      ? "N/A"
                      : "${_format.format(DateTime.fromMillisecondsSinceEpoch(userInfo.registerDate * 1000))}",
                ),
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
                Html(
                  data: userInfo == null
                      ? ""
                      : NgaContentParser.parse(userInfo.sign),
                )
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

    if (userInfo != null && userInfo.userForum != null) {
      final forumName = userInfo.userForum['1'];
      if (forumName != null) {
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
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TopicListPage(
                                fid: userInfo.userForum['0'],
                                name: forumName,
                              ))),
                      child: Text(
                        CodeUtils.unescapeHtml("[$forumName]"),
                        style: TextStyle(color: Palette.colorTextSubTitle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
