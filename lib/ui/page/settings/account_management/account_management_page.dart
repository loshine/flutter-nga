import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/store/account_list.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementState createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagementPage> {
  final _store = AccountList();
  final _refreshController = RefreshController();

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
      body: Observer(
        builder: (_) {
          return SmartRefresher(
            onRefresh: _onRefresh,
            enablePullUp: false,
            controller: _refreshController,
            child: ListView.builder(
              itemCount: _store.list.length,
              itemBuilder: (context, position) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Fluttertoast.showToast(
                      msg: _store.list[position].nickname),
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
          );
        },
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
    Future.delayed(const Duration(milliseconds: 0)).then((val) {
      _refreshController.requestRefresh();
    });
  }

  _onRefresh() {
    _store.refresh().whenComplete(() => _refreshController.refreshCompleted());
  }

  _quitAll() {
    _store
        .quitAll()
        .then((_) => Fluttertoast.showToast(
              msg: "成功",
              gravity: ToastGravity.CENTER,
            ))
        .whenComplete(() => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(title: 'NGA')),
            (Route<dynamic> route) => false));
  }
}
