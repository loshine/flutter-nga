// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BlocklistSettingsStore on _BlocklistSettingsStore, Store {
  final _$clientBlockEnabledAtom =
      Atom(name: '_BlocklistSettingsStore.clientBlockEnabled');

  @override
  bool get clientBlockEnabled {
    _$clientBlockEnabledAtom.reportRead();
    return super.clientBlockEnabled;
  }

  @override
  set clientBlockEnabled(bool value) {
    _$clientBlockEnabledAtom.reportWrite(value, super.clientBlockEnabled, () {
      super.clientBlockEnabled = value;
    });
  }

  final _$listBlockEnabledAtom =
      Atom(name: '_BlocklistSettingsStore.listBlockEnabled');

  @override
  bool get listBlockEnabled {
    _$listBlockEnabledAtom.reportRead();
    return super.listBlockEnabled;
  }

  @override
  set listBlockEnabled(bool value) {
    _$listBlockEnabledAtom.reportWrite(value, super.listBlockEnabled, () {
      super.listBlockEnabled = value;
    });
  }

  final _$detailsBlockEnabledAtom =
      Atom(name: '_BlocklistSettingsStore.detailsBlockEnabled');

  @override
  bool get detailsBlockEnabled {
    _$detailsBlockEnabledAtom.reportRead();
    return super.detailsBlockEnabled;
  }

  @override
  set detailsBlockEnabled(bool value) {
    _$detailsBlockEnabledAtom.reportWrite(value, super.detailsBlockEnabled, () {
      super.detailsBlockEnabled = value;
    });
  }

  final _$blockModeAtom = Atom(name: '_BlocklistSettingsStore.blockMode');

  @override
  BlockMode get blockMode {
    _$blockModeAtom.reportRead();
    return super.blockMode;
  }

  @override
  set blockMode(BlockMode value) {
    _$blockModeAtom.reportWrite(value, super.blockMode, () {
      super.blockMode = value;
    });
  }

  final _$blockUserListAtom =
      Atom(name: '_BlocklistSettingsStore.blockUserList');

  @override
  List<String> get blockUserList {
    _$blockUserListAtom.reportRead();
    return super.blockUserList;
  }

  @override
  set blockUserList(List<String> value) {
    _$blockUserListAtom.reportWrite(value, super.blockUserList, () {
      super.blockUserList = value;
    });
  }

  final _$blockWordListAtom =
      Atom(name: '_BlocklistSettingsStore.blockWordList');

  @override
  List<String> get blockWordList {
    _$blockWordListAtom.reportRead();
    return super.blockWordList;
  }

  @override
  set blockWordList(List<String> value) {
    _$blockWordListAtom.reportWrite(value, super.blockWordList, () {
      super.blockWordList = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_BlocklistSettingsStore.load');

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  final _$deleteUserAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteUser');

  @override
  Future<String> deleteUser(String user) {
    return _$deleteUserAsyncAction.run(() => super.deleteUser(user));
  }

  final _$deleteAllUsersAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteAllUsers');

  @override
  Future<String> deleteAllUsers() {
    return _$deleteAllUsersAsyncAction.run(() => super.deleteAllUsers());
  }

  final _$deleteWordAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteWord');

  @override
  Future<String> deleteWord(String word) {
    return _$deleteWordAsyncAction.run(() => super.deleteWord(word));
  }

  final _$deleteAllWordsAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteAllWords');

  @override
  Future<String> deleteAllWords() {
    return _$deleteAllWordsAsyncAction.run(() => super.deleteAllWords());
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
  void setClientBlockEnabled(bool enabled) {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.setClientBlockEnabled');
    try {
      return super.setClientBlockEnabled(enabled);
    } finally {
      _$_BlocklistSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setListBlockEnabled(bool enabled) {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.setListBlockEnabled');
    try {
      return super.setListBlockEnabled(enabled);
    } finally {
      _$_BlocklistSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDetailsBlockEnabled(bool enabled) {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.setDetailsBlockEnabled');
    try {
      return super.setDetailsBlockEnabled(enabled);
    } finally {
      _$_BlocklistSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
clientBlockEnabled: ${clientBlockEnabled},
listBlockEnabled: ${listBlockEnabled},
detailsBlockEnabled: ${detailsBlockEnabled},
blockMode: ${blockMode},
blockUserList: ${blockUserList},
blockWordList: ${blockWordList}
    ''';
  }
}
