import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeDrawerHeader extends HookConsumerWidget {
  const HomeDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(homeDrawerHeaderProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(homeDrawerHeaderProvider.notifier).refresh();
      });
      return null;
    }, []);

    return InkWell(
      onTap: () => _maybeGoLogin(context, userInfo != null),
      child: Container(
        height: 240.0,
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: AvatarWidget(
                userInfo != null ? userInfo.avatar : "",
                size: 56,
                username: userInfo != null ? userInfo.username : "",
              ),
            ),
            Text(
              userInfo != null ? userInfo.username! : "点击登陆",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _maybeGoLogin(BuildContext context, bool isLoggedIn) async {
    if (isLoggedIn) return;
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
        color: Theme.of(context).scaffoldBackgroundColor,
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
                      color: Theme.of(context).textTheme.bodyMedium?.color),
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
              color: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.all(16),
              height: 56,
              child: Align(
                child: Text(
                  "其它",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
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
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Material(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("关于"),
                ),
                onTap: () {},
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
