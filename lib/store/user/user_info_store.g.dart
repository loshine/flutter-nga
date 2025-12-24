// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserInfoStore on _UserInfoStore, Store {
  late final _$stateAtom = Atom(name: '_UserInfoStore.state', context: context);

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

  late final _$loadByNameAsyncAction =
      AsyncAction('_UserInfoStore.loadByName', context: context);

  @override
  Future<UserInfoStoreData> loadByName(String? username) {
    return _$loadByNameAsyncAction.run(() => super.loadByName(username));
  }

  late final _$loadByUidAsyncAction =
      AsyncAction('_UserInfoStore.loadByUid', context: context);

  @override
  Future<UserInfoStoreData> loadByUid(String? uid) {
    return _$loadByUidAsyncAction.run(() => super.loadByUid(uid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
