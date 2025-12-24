// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_drawer_header_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeDrawerHeaderStore on _HomeDrawerHeaderStore, Store {
  late final _$userInfoAtom =
      Atom(name: '_HomeDrawerHeaderStore.userInfo', context: context);

  @override
  UserInfo? get userInfo {
    _$userInfoAtom.reportRead();
    return super.userInfo;
  }

  @override
  set userInfo(UserInfo? value) {
    _$userInfoAtom.reportWrite(value, super.userInfo, () {
      super.userInfo = value;
    });
  }

  late final _$refreshAsyncAction =
      AsyncAction('_HomeDrawerHeaderStore.refresh', context: context);

  @override
  Future<dynamic> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  @override
  String toString() {
    return '''
userInfo: ${userInfo}
    ''';
  }
}
