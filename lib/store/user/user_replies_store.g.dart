// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_replies_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserRepliesStore on _UserRepliesStore, Store {
  late final _$stateAtom =
      Atom(name: '_UserRepliesStore.state', context: context);

  @override
  UserRepliesStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(UserRepliesStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$refreshAsyncAction =
      AsyncAction('_UserRepliesStore.refresh', context: context);

  @override
  Future<UserRepliesStoreData> refresh(int authorid) {
    return _$refreshAsyncAction.run(() => super.refresh(authorid));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_UserRepliesStore.loadMore', context: context);

  @override
  Future<UserRepliesStoreData> loadMore(int authorid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(authorid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
