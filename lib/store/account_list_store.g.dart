// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountListStore on _AccountListStore, Store {
  final _$listAtom = Atom(name: '_AccountListStore.list');

  @override
  List<User> get list {
    _$listAtom.context.enforceReadPolicy(_$listAtom);
    _$listAtom.reportObserved();
    return super.list;
  }

  @override
  set list(List<User> value) {
    _$listAtom.context.conditionallyRunInAction(() {
      super.list = value;
      _$listAtom.reportChanged();
    }, _$listAtom, name: '${_$listAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<dynamic> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$_AccountListStoreActionController =
      ActionController(name: '_AccountListStore');

  @override
  Future<int> quitAll() {
    final _$actionInfo = _$_AccountListStoreActionController.startAction();
    try {
      return super.quitAll();
    } finally {
      _$_AccountListStoreActionController.endAction(_$actionInfo);
    }
  }
}
