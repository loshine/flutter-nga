// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_topic_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchTopicListStore on _SearchTopicListStore, Store {
  final _$stateAtom = Atom(name: '_SearchTopicListStore.state');

  @override
  SearchTopicListStoreData get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(SearchTopicListStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<SearchTopicListStoreData> refresh(
      String keyword, int fid, bool content) {
    return _$refreshAsyncAction.run(() => super.refresh(keyword, fid, content));
  }

  final _$loadMoreAsyncAction = AsyncAction('loadMore');

  @override
  Future<SearchTopicListStoreData> loadMore(
      String keyword, int fid, bool content) {
    return _$loadMoreAsyncAction
        .run(() => super.loadMore(keyword, fid, content));
  }
}
