import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/user/user_info_store.dart';
import 'package:flutter_nga/ui/widget/info_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserInfoPage extends StatefulWidget {
  final String? username;
  final String? uid;

  const UserInfoPage({this.username, this.uid, Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _store = UserInfoStore();
  final _actions = const ["发布的主题", "发布的回复"];

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      _store.loadByUid(widget.uid).catchError((err) {
        Fluttertoast.showToast(msg: err.message);
      });
    } else if (widget.username != null) {
      _store.loadByName(widget.username).catchError((err) {
        Fluttertoast.showToast(msg: err.message);
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
                actions: [
                  PopupMenuButton(
                    child: Icon(Icons.more_vert),
                    onSelected: _onMenuSelected,
                    itemBuilder: (BuildContext context) {
                      return _actions.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    _store.state.username!,
                    style: TextStyle(
                      color: Palette.colorWhite,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                      child: codeUtils.isStringEmpty(_store.state.avatar)
                          ? SizedBox.expand(child: Text(""))
                          : CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: _store.state.realAvatarUrl,
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

  List<Widget> _getAdminForumWidgets(UserInfoStoreData userInfo) {
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 管理权限 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.getColorTextSubtitle(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Text(
        "在以下版面担任版主",
        style: TextStyle(color: Theme.of(context).textTheme.bodyText2?.color),
      )
    ];

    if (userInfo.moderatorForums!.isNotEmpty) {
      widgets.addAll(userInfo.moderatorForums!.entries.map(
        (entry) => Builder(
            builder: (context) => GestureDetector(
                  onTap: () => Routes.navigateTo(context,
                      "${Routes.FORUM_DETAIL}?fid=${entry.key}&name=${codeUtils.fluroCnParamsEncode(entry.value)}"),
                  child: Text(
                    "[${entry.value}]",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )),
      ));
    } else {
      widgets.add(Text("无管理版块"));
    }
    return widgets;
  }

  List<Widget> _getReputationWidgets(UserInfoStoreData userInfo) {
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 声望 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.getColorTextSubtitle(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Text(
        "表示与 论坛/某版面/某用户 的关系",
        style: TextStyle(color: Theme.of(context).textTheme.bodyText2?.color),
      )
    ];
    widgets.addAll(userInfo.reputationMap!.entries.map((entry) => InfoWidget(
          title: "${entry.key}: ",
          subTitle: entry.value,
        )));
    return widgets;
  }

  List<Widget> _getBodyWidgets(UserInfoStoreData userInfo) {
    List<Widget> basicWidgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          ":: 基础信息 ::",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.getColorTextSubtitle(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    basicWidgets.addAll(userInfo.basicInfoMap!.entries.map(
        (entry) => InfoWidget(title: "${entry.key}: ", subTitle: entry.value)));

    List<Widget> widgets = [
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Palette.getColorUserInfoCard(context),
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
        color: Palette.getColorUserInfoCard(context),
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
                      color: Palette.getColorTextSubtitle(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Html(data: userInfo.signature!)
              ],
            ),
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
        color: Palette.getColorUserInfoCard(context),
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
        color: Palette.getColorUserInfoCard(context),
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

    if (userInfo.personalForum!.isNotEmpty) {
      widgets.add(
        Card(
          margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
          color: Palette.getColorUserInfoCard(context),
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
                        color: Palette.getColorTextSubtitle(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "个人版面是由用户自己管理的版面",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2?.color),
                  ),
                  Builder(builder: (context) {
                    final entry = userInfo.personalForum!.entries.toList()[0];
                    return GestureDetector(
                      onTap: () => Routes.navigateTo(context,
                          "${Routes.FORUM_DETAIL}?fid=${entry.key}&name=${codeUtils.fluroCnParamsEncode(entry.value)}"),
                      child: Text(
                        "[${entry.value}]",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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

    widgets.add(SizedBox.fromSize(
      size: Size(double.infinity, 40),
    ));
    return widgets;
  }

  _onMenuSelected(String action) {
    if (action == _actions[0]) {
      // 跳转某人的主题
      Routes.navigateTo(context,
          "${Routes.USER_TOPICS}?uid=${_store.state.uid}&username=${codeUtils.fluroCnParamsEncode(_store.state.username ?? "")}");
    } else if (action == _actions[1]) {
      // 跳转某人的回复
      Routes.navigateTo(context,
          "${Routes.USER_REPLIES}?uid=${_store.state.uid}&username=${codeUtils.fluroCnParamsEncode(_store.state.username ?? "")}");
    }
  }
}
