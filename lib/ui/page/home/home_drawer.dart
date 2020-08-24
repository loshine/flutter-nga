import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/home_drawer_header_store.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class HomeDrawerHeader extends StatefulWidget {
  const HomeDrawerHeader({Key key}) : super(key: key);

  @override
  _HomeDrawerHeaderState createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
  HomeDrawerHeaderStore _store;

  @override
  Widget build(BuildContext context) {
    _store = Provider.of(context);
    _store.refresh();
    return InkWell(
      onTap: () => _maybeGoLogin(context),
      child: Container(
        height: 240.0,
        width: double.infinity,
        color: Palette.colorBackground,
        child: Observer(
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: AvatarWidget(
                    _store.userInfo != null ? _store.userInfo.avatar : "",
                    size: 56,
                    username:
                        _store.userInfo != null ? _store.userInfo.username : "",
                  ),
                ),
                Text(_store.userInfo != null
                    ? _store.userInfo.username
                    : "点击登陆"),
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
