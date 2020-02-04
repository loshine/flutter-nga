// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserInfoStore on _UserInfoStore, Store {
  final _$stateAtom = Atom(name: '_UserInfoStore.state');

  @override
  UserInfoStoreData get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(UserInfoStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$loadByNameAsyncAction = AsyncAction('loadByName');

  @override
  Future<UserInfoStoreData> loadByName(String username) {
    return _$loadByNameAsyncAction.run(() => super.loadByName(username));
  }

  final _$loadByUidAsyncAction = AsyncAction('loadByUid');

  @override
  Future<UserInfoStoreData> loadByUid(String uid) {
    return _$loadByUidAsyncAction.run(() => super.loadByUid(uid));
  }
}
