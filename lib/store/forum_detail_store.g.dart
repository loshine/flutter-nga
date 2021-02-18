// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ForumDetailStore on _ForumDetailStore, Store {
  final _$stateAtom = Atom(name: '_ForumDetailStore.state');

  @override
  ForumDetailStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(ForumDetailStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_ForumDetailStore.refresh');

  @override
  Future<ForumDetailStoreData> refresh(int fid, bool recommend) {
    return _$refreshAsyncAction.run(() => super.refresh(fid, recommend));
  }

  final _$loadMoreAsyncAction = AsyncAction('_ForumDetailStore.loadMore');

  @override
  Future<ForumDetailStoreData> loadMore(int fid, bool recommend) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(fid, recommend));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
