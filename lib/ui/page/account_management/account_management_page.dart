import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/store/user/account_list_store.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementState createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagementPage>
    with RouteAware, RouteObserverMixin {
  final _store = AccountListStore();
  late RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("账号管理"),
        actions: [
          IconButton(
            onPressed: _quitAll,
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "退出所有账号",
          ),
        ],
      ),
      body: SmartRefresher(
        onRefresh: _onRefresh,
        enablePullUp: false,
        controller: _refreshController,
        child: Observer(
          builder: (_) => ListView.builder(
            itemCount: _store.list.length,
            itemBuilder: (context, position) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _setDefault(_store.list[position]),
                onLongPress: () => _showDeleteDialog(_store.list[position]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        _store.list[position].nickname,
                        style: TextStyle(
                            color: _store.list[position].enabled
                                ? Palette.getColorPrimary(context)
                                : Theme.of(context).textTheme.bodyText1?.color),
                      ),
                      subtitle: Text(
                        "UID:${_store.list[position].uid}",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText2?.color),
                      ),
                      trailing: Icon(
                        CommunityMaterialIcons.check,
                        color: Palette.getColorPrimary(context),
                      ),
                    ),
                    Divider(height: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "添加账号",
        onPressed: () => Routes.navigateTo(context, Routes.LOGIN),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshController.requestRefresh();
  }

  _onRefresh() {
    _store
        .refresh()
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((_) => _refreshController.refreshFailed());
  }

  _quitAll() {
    _store
        .quitAll()
        .then((_) => Fluttertoast.showToast(msg: "成功"))
        .whenComplete(
            () => Routes.navigateTo(context, Routes.HOME, clearStack: true));
  }

  _setDefault(CacheUser user) {
    _store.setDefault(user).then((_) => _refreshController.requestRefresh());
  }

  _showDeleteDialog(CacheUser user) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该登录用户"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  _store
                      .delete(user)
                      .then((_) => _refreshController.requestRefresh());
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
