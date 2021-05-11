// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_topics_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserTopicsStore on _UserTopicsStore, Store {
  final _$stateAtom = Atom(name: '_UserTopicsStore.state');

  @override
  UserTopicsStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UserTopicsStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_UserTopicsStore.refresh');

  @override
  Future<UserTopicsStoreData> refresh(int authorid) {
    return _$refreshAsyncAction.run(() => super.refresh(authorid));
  }

  final _$loadMoreAsyncAction = AsyncAction('_UserTopicsStore.loadMore');

  @override
  Future<UserTopicsStoreData> loadMore(int authorid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(authorid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
