// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchStore on _SearchStore, Store {
  final _$searchByUsernameAsyncAction = AsyncAction('searchByUsername');

  @override
  Future<UserInfo> searchByUsername(String username) {
    return _$searchByUsernameAsyncAction
        .run(() => super.searchByUsername(username));
  }
}
