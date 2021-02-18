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
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(TopicHistoryListStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_TopicHistoryListStore.refresh');

  @override
  Future<TopicHistoryListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$loadMoreAsyncAction = AsyncAction('_TopicHistoryListStore.loadMore');

  @override
  Future<TopicHistoryListStoreData> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  final _$_TopicHistoryListStoreActionController =
      ActionController(name: '_TopicHistoryListStore');

  @override
  Future<dynamic> delete(int id) {
    final _$actionInfo = _$_TopicHistoryListStoreActionController.startAction(
        name: '_TopicHistoryListStore.delete');
    try {
      return super.delete(id);
    } finally {
      _$_TopicHistoryListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<int> clean() {
    final _$actionInfo = _$_TopicHistoryListStoreActionController.startAction(
        name: '_TopicHistoryListStore.clean');
    try {
      return super.clean();
    } finally {
      _$_TopicHistoryListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
