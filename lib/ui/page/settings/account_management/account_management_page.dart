import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_bloc.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementState createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagementPage> {
  final _bloc = AccountManagementBloc();
  final _refreshController = RefreshController();
  final _quitAllCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("账号管理"),
        actions: [
          IconButton(
            onPressed: () => _bloc.onQuitAll(_quitAllCompleter),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "退出所有账号",
          ),
        ],
      ),
      body: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, AccountManagementState state) {
          return SmartRefresher(
            onRefresh: _onRefresh,
            enablePullUp: false,
            controller: _refreshController,
            child: ListView.builder(
              itemCount: state.accountList.length,
              itemBuilder: (context, position) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Fluttertoast.showToast(
                      msg: state.accountList[position].nickname),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(state.accountList[position].nickname),
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
    _quitAllCompleter.future.asStream().listen((d) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(title: 'NGA')),
            (Route<dynamic> route) => false));
  }

  _onRefresh() {
    _bloc.onRefresh(_refreshController);
  }
}
