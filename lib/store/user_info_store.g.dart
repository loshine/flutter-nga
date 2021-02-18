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
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UserInfoStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$loadByNameAsyncAction = AsyncAction('_UserInfoStore.loadByName');

  @override
  Future<UserInfoStoreData> loadByName(String username) {
    return _$loadByNameAsyncAction.run(() => super.loadByName(username));
  }

  final _$loadByUidAsyncAction = AsyncAction('_UserInfoStore.loadByUid');

  @override
  Future<UserInfoStoreData> loadByUid(String uid) {
    return _$loadByUidAsyncAction.run(() => super.loadByUid(uid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
