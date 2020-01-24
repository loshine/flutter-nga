// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicListStore on _TopicListStore, Store {
  final _$stateAtom = Atom(name: '_TopicListStore.state');

  @override
  TopicListState get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(TopicListState value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<TopicListState> refresh(int fid) {
    return _$refreshAsyncAction.run(() => super.refresh(fid));
  }

  final _$loadMoreAsyncAction = AsyncAction('loadMore');

  @override
  Future<TopicListState> loadMore(int fid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(fid));
  }
}
