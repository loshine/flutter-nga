// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_topic_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavouriteTopicListStore on _FavouriteTopicListStore, Store {
  late final _$stateAtom =
      Atom(name: '_FavouriteTopicListStore.state', context: context);

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

  late final _$refreshAsyncAction =
      AsyncAction('_FavouriteTopicListStore.refresh', context: context);

  @override
  Future<FavouriteTopicListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_FavouriteTopicListStore.loadMore', context: context);

  @override
  Future<FavouriteTopicListStoreData> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  late final _$deleteAsyncAction =
      AsyncAction('_FavouriteTopicListStore.delete', context: context);

  @override
  Future<String?> delete(Topic topic) {
    return _$deleteAsyncAction.run(() => super.delete(topic));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
