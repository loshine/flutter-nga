import 'dart:async';

import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class AccountManagementEvent {
  const AccountManagementEvent();

  factory AccountManagementEvent.refresh(RefreshController controller) =>
      AccountRefreshEvent(controller);

  factory AccountManagementEvent.quit(String uid) => AccountQuitEvent(uid);

  factory AccountManagementEvent.quitAll(Completer completer) =>
      AccountQuitAllEvent(completer);

  factory AccountManagementEvent.activate(String uid) =>
      AccountActivateEvent(uid);
}

class AccountRefreshEvent extends AccountManagementEvent {
  final RefreshController controller;

  const AccountRefreshEvent(this.controller);
}

class AccountQuitEvent extends AccountManagementEvent {
  final String uid;

  const AccountQuitEvent(this.uid);
}

class AccountQuitAllEvent extends AccountManagementEvent {
  final Completer completer;

  const AccountQuitAllEvent(this.completer);
}

class AccountActivateEvent extends AccountManagementEvent {
  final String uid;

  const AccountActivateEvent(this.uid);
}
