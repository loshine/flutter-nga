// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ForumDetailStore on _ForumDetailStore, Store {
  late final _$stateAtom =
      Atom(name: '_ForumDetailStore.state', context: context);

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

  late final _$refreshAsyncAction =
      AsyncAction('_ForumDetailStore.refresh', context: context);

  @override
  Future<ForumDetailStoreData> refresh(int fid, bool recommend, int? type) {
    return _$refreshAsyncAction.run(() => super.refresh(fid, recommend, type));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_ForumDetailStore.loadMore', context: context);

  @override
  Future<ForumDetailStoreData> loadMore(int fid, bool recommend, int? type) {
    return _$loadMoreAsyncAction
        .run(() => super.loadMore(fid, recommend, type));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
