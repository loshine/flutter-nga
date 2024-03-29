import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/home/home_drawer_header_store.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class HomeDrawerHeader extends StatefulWidget {
  const HomeDrawerHeader({Key? key}) : super(key: key);

  @override
  _HomeDrawerHeaderState createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
  late HomeDrawerHeaderStore _store;

  @override
  Widget build(BuildContext context) {
    _store = Provider.of(context);
    _store.refresh();
    return InkWell(
      onTap: () => _maybeGoLogin(context),
      child: Container(
        height: 240.0,
        width: double.infinity,
        color: Theme.of(context).backgroundColor,
        child: Observer(
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: AvatarWidget(
                    _store.userInfo != null ? _store.userInfo!.avatar : "",
                    size: 56,
                    username: _store.userInfo != null
                        ? _store.userInfo!.username
                        : "",
                  ),
                ),
                Text(
                  _store.userInfo != null ? _store.userInfo!.username! : "点击登陆",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1?.color,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _maybeGoLogin(BuildContext context) async {
    if (_store.userInfo != null) return;
    Routes.pop(context);
    Routes.navigateTo(context, Routes.LOGIN);
  }
}

class HomeDrawerBody extends StatelessWidget {
  final int? currentSelection;
  final Function(int)? onSelectedCallback;

  const HomeDrawerBody(
      {Key? key, this.currentSelection, this.onSelectedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          children: [
            Divider(height: 1),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              child: Align(
                child: Text(
                  "模块",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText2?.color),
                  textAlign: TextAlign.left,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(CommunityMaterialIcons.view_dashboard),
                  title: Text("论坛"),
                  selected: currentSelection == 0,
                  selectedTileColor:
                      Palette.getColorDrawerListTileBackground(context),
                ),
                onTap: () => onSelectedCallback?.call(0),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(CommunityMaterialIcons.archive),
                  title: Text("贴子收藏"),
                  selected: currentSelection == 1,
                  selectedTileColor:
                      Palette.getColorDrawerListTileBackground(context),
                ),
                onTap: () => onSelectedCallback?.call(1),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(CommunityMaterialIcons.history),
                  title: Text("浏览历史"),
                  selected: currentSelection == 2,
                  selectedTileColor:
                      Palette.getColorDrawerListTileBackground(context),
                ),
                onTap: () => onSelectedCallback?.call(2),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.message),
                  title: Text("短消息"),
                  selected: currentSelection == 3,
                  selectedTileColor:
                      Palette.getColorDrawerListTileBackground(context),
                ),
                onTap: () => onSelectedCallback?.call(3),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.notifications_rounded),
                  title: Text("提醒信息"),
                  selected: currentSelection == 4,
                  selectedTileColor:
                      Palette.getColorDrawerListTileBackground(context),
                ),
                onTap: () => onSelectedCallback?.call(4),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.all(16),
              height: 56,
              child: Align(
                child: Text(
                  "其它",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText2?.color),
                  textAlign: TextAlign.left,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("设置"),
                ),
                onTap: () => Routes.navigateTo(context, Routes.SETTINGS),
              ),
              color: Theme.of(context).backgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("关于"),
                ),
                onTap: () {
                  // TODO: 点击关于
                },
              ),
              color: Theme.of(context).backgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
