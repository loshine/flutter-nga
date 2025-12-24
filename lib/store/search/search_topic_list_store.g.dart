// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_topic_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SearchTopicListStore on _SearchTopicListStore, Store {
  late final _$stateAtom =
      Atom(name: '_SearchTopicListStore.state', context: context);

  @override
  SearchTopicListStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(SearchTopicListStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$refreshAsyncAction =
      AsyncAction('_SearchTopicListStore.refresh', context: context);

  @override
  Future<SearchTopicListStoreData> refresh(
      String keyword, int? fid, bool content) {
    return _$refreshAsyncAction.run(() => super.refresh(keyword, fid, content));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_SearchTopicListStore.loadMore', context: context);

  @override
  Future<SearchTopicListStoreData> loadMore(
      String keyword, int? fid, bool content) {
    return _$loadMoreAsyncAction
        .run(() => super.loadMore(keyword, fid, content));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
