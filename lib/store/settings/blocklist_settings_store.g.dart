// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BlocklistSettingsStore on _BlocklistSettingsStore, Store {
  final _$clientEnabledAtom =
      Atom(name: '_BlocklistSettingsStore.clientEnabled');

  @override
  bool get clientEnabled {
    _$clientEnabledAtom.reportRead();
    return super.clientEnabled;
  }

  @override
  set clientEnabled(bool value) {
    _$clientEnabledAtom.reportWrite(value, super.clientEnabled, () {
      super.clientEnabled = value;
    });
  }

  final _$blockUserListAtom =
      Atom(name: '_BlocklistSettingsStore.blockUserList');

  @override
  List<dynamic> get blockUserList {
    _$blockUserListAtom.reportRead();
    return super.blockUserList;
  }

  @override
  set blockUserList(List<dynamic> value) {
    _$blockUserListAtom.reportWrite(value, super.blockUserList, () {
      super.blockUserList = value;
    });
  }

  final _$blockWordListAtom =
      Atom(name: '_BlocklistSettingsStore.blockWordList');

  @override
  List<dynamic> get blockWordList {
    _$blockWordListAtom.reportRead();
    return super.blockWordList;
  }

  @override
  set blockWordList(List<dynamic> value) {
    _$blockWordListAtom.reportWrite(value, super.blockWordList, () {
      super.blockWordList = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_BlocklistSettingsStore.load');

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  final _$_BlocklistSettingsStoreActionController =
      ActionController(name: '_BlocklistSettingsStore');

  @override
  void init() {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.init');
    try {
      return super.init();
    } finally {
      _$_BlocklistSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setClientEnabled(bool enabled) {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.setClientEnabled');
    try {
      return super.setClientEnabled(enabled);
    } finally {
      _$_BlocklistSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
clientEnabled: ${clientEnabled},
blockUserList: ${blockUserList},
blockWordList: ${blockWordList}
    ''';
  }
}
