import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/topic/topic_list.dart';
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
  UserInfo _userInfo;
  final _format = DateFormat('yyyy-MM-dd hh:mm:ss');

  @override
  void initState() {
    super.initState();
    Data()
        .userRepository
        .getUserInfo(widget.username)
        .then((user) => setState(() => _userInfo = user))
        .catchError((err) => Fluttertoast.instance.showToast(
              msg: err.message,
              gravity: ToastGravity.CENTER,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                _userInfo == null ? "" : _userInfo.username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              background: Container(
                  child: _userInfo == null
                      ? SizedBox.expand()
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _userInfo.avatar,
                          placeholder:
                              Image.asset('images/default_forum_icon.png'),
                          errorWidget:
                              Image.asset('images/default_forum_icon.png'),
                        ),
                  foregroundDecoration: BoxDecoration(color: Colors.black38)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(_getBodyWidgets()),
          )
        ],
      ),
    );
  }

  List<Widget> _getAdminForumWidgets() {
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

    if (_userInfo != null &&
        _userInfo.adminForums != null &&
        _userInfo.adminForums.isNotEmpty) {
      widgets.addAll(_userInfo.adminForums.entries.map(
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

  List<Widget> _getReputationWidgets() {
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
      subTitle: "${_userInfo == null ? 0 : _userInfo.fame / 10}",
    ));
    if (_userInfo != null &&
        _userInfo.reputation != null &&
        _userInfo.reputation.isNotEmpty) {
      widgets.addAll(_userInfo.reputation.map((reputation) => InfoWidget(
            title: "${reputation.name}: ",
            subTitle: "${reputation.value}",
          )));
    }
    return widgets;
  }

  List<Widget> _getBodyWidgets() {
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
                  subTitle: _userInfo == null ? "N/A" : "${_userInfo.uid}",
                ),
                InfoWidget(
                  title: "用户名: ",
                  subTitle: _userInfo == null ? "N/A" : "${_userInfo.username}",
                ),
                InfoWidget(
                  title: "用户组: ",
                  subTitle: _userInfo == null
                      ? "N/A"
                      : "${_userInfo.group}(${_userInfo.groupId})",
                ),
                InfoWidget(
                  title: "财富: ",
                  subTitle: _userInfo == null || _userInfo.money == null
                      ? "N/A"
                      : "${_userInfo.money ~/ 10000}金 ${(_userInfo.money % 10000) ~/ 100}银 ${_userInfo.money % 100}铜",
                ),
                InfoWidget(
                  title: "注册日期: ",
                  subTitle: _userInfo == null
                      ? "N/A"
                      : "${_format.format(DateTime.fromMillisecondsSinceEpoch(_userInfo.registerDate * 1000))}",
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
                  data: _userInfo == null
                      ? ""
                      : NgaContentParser.parse(_userInfo.sign),
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
              children: _getAdminForumWidgets(),
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
              children: _getReputationWidgets(),
            ),
          ),
        ),
      ),
    ];

    if (_userInfo != null && _userInfo.userForum != null) {
      final forumName = _userInfo.userForum['1'];
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
                                fid: _userInfo.userForum['0'],
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
