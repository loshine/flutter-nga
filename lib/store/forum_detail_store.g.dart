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
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(ForumDetailStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<ForumDetailStoreData> refresh(int fid) {
    return _$refreshAsyncAction.run(() => super.refresh(fid));
  }

  final _$loadMoreAsyncAction = AsyncAction('loadMore');

  @override
  Future<ForumDetailStoreData> loadMore(int fid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(fid));
  }
}
