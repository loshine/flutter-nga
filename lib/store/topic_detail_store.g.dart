// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicDetailStore on _TopicDetailStore, Store {
  final _$stateAtom = Atom(name: '_TopicDetailStore.state');

  @override
  TopicDetailState get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(TopicDetailState value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<TopicDetailState> refresh(int tid) {
    return _$refreshAsyncAction.run(() => super.refresh(tid));
  }

  final _$loadMoreAsyncAction = AsyncAction('loadMore');

  @override
  Future<TopicDetailState> loadMore(int tid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(tid));
  }
}
