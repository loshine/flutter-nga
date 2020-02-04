// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_history_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicHistoryListStore on _TopicHistoryListStore, Store {
  final _$stateAtom = Atom(name: '_TopicHistoryListStore.state');

  @override
  TopicHistoryListStoreData get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(TopicHistoryListStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$_TopicHistoryListStoreActionController =
      ActionController(name: '_TopicHistoryListStore');

  @override
  Future<TopicHistoryListStoreData> refresh() {
    final _$actionInfo = _$_TopicHistoryListStoreActionController.startAction();
    try {
      return super.refresh();
    } finally {
      _$_TopicHistoryListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<TopicHistoryListStoreData> loadMore() {
    final _$actionInfo = _$_TopicHistoryListStoreActionController.startAction();
    try {
      return super.loadMore();
    } finally {
      _$_TopicHistoryListStoreActionController.endAction(_$actionInfo);
    }
  }
}
