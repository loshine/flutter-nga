import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/ui/page/topic/topic_list.dart';
import 'package:flutter_nga/ui/page/user/user_info_state.dart';
import 'package:flutter_nga/ui/widget/info_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';

import 'user_info_bloc.dart';

class UserInfoPage extends StatefulWidget {
  final String username;

  const UserInfoPage(this.username, {Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserInfoBloc _userInfoBloc = UserInfoBloc();

  @override
  void dispose() {
    super.dispose();
    _userInfoBloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userInfoBloc.onLoad(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _userInfoBloc,
      child: UserInfoWidget(),
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder(
          bloc: BlocProvider.of<UserInfoBloc>(context),
          builder: (context, UserInfoState state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      state.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    background: Container(
                        child: CodeUtils.isStringEmpty(state.avatar)
                            ? SizedBox.expand(child: Text(""))
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: state.avatar,
                                placeholder: Image.asset(
                                    'images/default_forum_icon.png'),
                                errorWidget: Image.asset(
                                    'images/default_forum_icon.png'),
                              ),
                        foregroundDecoration:
                            BoxDecoration(color: Colors.black38)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(_getBodyWidgets(state)),
                ),
              ],
            );
          }),
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => TopicListPage(
                            fid: entry.key,
                            name: entry.value,
                          ))),
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
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TopicListPage(
                                fid: entry.key,
                                name: entry.value,
                              ))),
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
