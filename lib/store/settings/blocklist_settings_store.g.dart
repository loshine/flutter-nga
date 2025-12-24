// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BlocklistSettingsStore on _BlocklistSettingsStore, Store {
  late final _$clientBlockEnabledAtom = Atom(
      name: '_BlocklistSettingsStore.clientBlockEnabled', context: context);

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

  late final _$listBlockEnabledAtom =
      Atom(name: '_BlocklistSettingsStore.listBlockEnabled', context: context);

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

  late final _$detailsBlockEnabledAtom = Atom(
      name: '_BlocklistSettingsStore.detailsBlockEnabled', context: context);

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

  late final _$blockModeAtom =
      Atom(name: '_BlocklistSettingsStore.blockMode', context: context);

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

  late final _$blockUserListAtom =
      Atom(name: '_BlocklistSettingsStore.blockUserList', context: context);

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

  late final _$blockWordListAtom =
      Atom(name: '_BlocklistSettingsStore.blockWordList', context: context);

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

  late final _$initAsyncAction =
      AsyncAction('_BlocklistSettingsStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$setClientBlockEnabledAsyncAction = AsyncAction(
      '_BlocklistSettingsStore.setClientBlockEnabled',
      context: context);

  @override
  Future<void> setClientBlockEnabled(bool enabled) {
    return _$setClientBlockEnabledAsyncAction
        .run(() => super.setClientBlockEnabled(enabled));
  }

  late final _$setListBlockEnabledAsyncAction = AsyncAction(
      '_BlocklistSettingsStore.setListBlockEnabled',
      context: context);

  @override
  Future<void> setListBlockEnabled(bool enabled) {
    return _$setListBlockEnabledAsyncAction
        .run(() => super.setListBlockEnabled(enabled));
  }

  late final _$setDetailsBlockEnabledAsyncAction = AsyncAction(
      '_BlocklistSettingsStore.setDetailsBlockEnabled',
      context: context);

  @override
  Future<void> setDetailsBlockEnabled(bool enabled) {
    return _$setDetailsBlockEnabledAsyncAction
        .run(() => super.setDetailsBlockEnabled(enabled));
  }

  late final _$loadAsyncAction =
      AsyncAction('_BlocklistSettingsStore.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$addUserAsyncAction =
      AsyncAction('_BlocklistSettingsStore.addUser', context: context);

  @override
  Future<String> addUser(String user) {
    return _$addUserAsyncAction.run(() => super.addUser(user));
  }

  late final _$deleteUserAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteUser', context: context);

  @override
  Future<String> deleteUser(String user) {
    return _$deleteUserAsyncAction.run(() => super.deleteUser(user));
  }

  late final _$deleteAllUsersAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteAllUsers', context: context);

  @override
  Future<String> deleteAllUsers() {
    return _$deleteAllUsersAsyncAction.run(() => super.deleteAllUsers());
  }

  late final _$addWordAsyncAction =
      AsyncAction('_BlocklistSettingsStore.addWord', context: context);

  @override
  Future<String> addWord(String word) {
    return _$addWordAsyncAction.run(() => super.addWord(word));
  }

  late final _$deleteWordAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteWord', context: context);

  @override
  Future<String> deleteWord(String word) {
    return _$deleteWordAsyncAction.run(() => super.deleteWord(word));
  }

  late final _$deleteAllWordsAsyncAction =
      AsyncAction('_BlocklistSettingsStore.deleteAllWords', context: context);

  @override
  Future<String> deleteAllWords() {
    return _$deleteAllWordsAsyncAction.run(() => super.deleteAllWords());
  }

  late final _$updateBlockModeAsyncAction =
      AsyncAction('_BlocklistSettingsStore.updateBlockMode', context: context);

  @override
  Future<void> updateBlockMode(BlockMode mode) {
    return _$updateBlockModeAsyncAction.run(() => super.updateBlockMode(mode));
  }

  late final _$_BlocklistSettingsStoreActionController =
      ActionController(name: '_BlocklistSettingsStore', context: context);

  @override
  dynamic loopSyncBlockList() {
    final _$actionInfo = _$_BlocklistSettingsStoreActionController.startAction(
        name: '_BlocklistSettingsStore.loopSyncBlockList');
    try {
      return super.loopSyncBlockList();
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
