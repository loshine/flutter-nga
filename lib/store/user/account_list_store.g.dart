// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AccountListStore on _AccountListStore, Store {
  late final _$listAtom =
      Atom(name: '_AccountListStore.list', context: context);

  @override
  List<CacheUser> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(List<CacheUser> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  late final _$refreshAsyncAction =
      AsyncAction('_AccountListStore.refresh', context: context);

  @override
  Future<dynamic> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$_AccountListStoreActionController =
      ActionController(name: '_AccountListStore', context: context);

  @override
  Future<int> quitAll() {
    final _$actionInfo = _$_AccountListStoreActionController.startAction(
        name: '_AccountListStore.quitAll');
    try {
      return super.quitAll();
    } finally {
      _$_AccountListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> setDefault(CacheUser cacheUser) {
    final _$actionInfo = _$_AccountListStoreActionController.startAction(
        name: '_AccountListStore.setDefault');
    try {
      return super.setDefault(cacheUser);
    } finally {
      _$_AccountListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<bool> delete(CacheUser cacheUser) {
    final _$actionInfo = _$_AccountListStoreActionController.startAction(
        name: '_AccountListStore.delete');
    try {
      return super.delete(cacheUser);
    } finally {
      _$_AccountListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
list: ${list}
    ''';
  }
}
