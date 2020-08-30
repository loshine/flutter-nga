import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/store/account_list_store.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementState createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagementPage> {
  final _store = AccountListStore();
  RefreshController _refreshController;

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
                onTap: () =>
                    Fluttertoast.showToast(msg: _store.list[position].nickname),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(_store.list[position].nickname),
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
        onPressed: () => AndroidLogin.startLogin(),
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

  _onRefresh() {
    _store
        .refresh()
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((_) => _refreshController.refreshFailed());
  }

  _quitAll() {
    _store
        .quitAll()
        .then((_) =>
            Fluttertoast.showToast(msg: "成功", gravity: ToastGravity.CENTER))
        .whenComplete(
            () => Routes.navigateTo(context, Routes.HOME, clearStack: true));
  }
}
