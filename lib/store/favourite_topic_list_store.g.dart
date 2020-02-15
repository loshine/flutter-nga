// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_topic_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FavouriteTopicListStore on _FavouriteTopicListStore, Store {
  final _$stateAtom = Atom(name: '_FavouriteTopicListStore.state');

  @override
  FavouriteTopicListStoreData get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(FavouriteTopicListStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<FavouriteTopicListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$loadMoreAsyncAction = AsyncAction('loadMore');

  @override
  Future<FavouriteTopicListStoreData> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  final _$deleteAsyncAction = AsyncAction('delete');

  @override
  Future<String> delete(Topic topic) {
    return _$deleteAsyncAction.run(() => super.delete(topic));
  }
}