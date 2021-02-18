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
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(FavouriteTopicListStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_FavouriteTopicListStore.refresh');

  @override
  Future<FavouriteTopicListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$loadMoreAsyncAction =
      AsyncAction('_FavouriteTopicListStore.loadMore');

  @override
  Future<FavouriteTopicListStoreData> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  final _$deleteAsyncAction = AsyncAction('_FavouriteTopicListStore.delete');

  @override
  Future<String> delete(Topic topic) {
    return _$deleteAsyncAction.run(() => super.delete(topic));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
