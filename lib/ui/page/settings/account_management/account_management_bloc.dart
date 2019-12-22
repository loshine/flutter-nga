import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_event.dart';
import 'package:flutter_nga/ui/page/settings/account_management/account_management_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountManagementBloc
    extends Bloc<AccountManagementEvent, AccountManagementState> {
  @override
  AccountManagementState get initialState => AccountManagementState.initial();

  void onRefresh(RefreshController controller) {
    add(AccountManagementEvent.refresh(controller));
  }

  void onQuitAll(Completer completer) {
    add(AccountManagementEvent.quitAll(completer));
  }

  @override
  Stream<AccountManagementState> mapEventToState(
      AccountManagementEvent event) async* {
    if (event is AccountRefreshEvent) {
      final list = await Data().userRepository.getAllLoginUser();
      yield AccountManagementState(list);
      event.controller.refreshCompleted();
    } else if (event is AccountQuitAllEvent) {
      final count = await Data().userRepository.quitAllLoginUser();
      Fluttertoast.showToast(
        msg: "成功",
        gravity: ToastGravity.CENTER,
      );
      event.completer.complete(count);
    }
  }
}
