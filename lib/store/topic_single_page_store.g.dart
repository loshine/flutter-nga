// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_single_page_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicSinglePageStore on _TopicSinglePageStore, Store {
  final _$stateAtom = Atom(name: '_TopicSinglePageStore.state');

  @override
  TopicSinglePageStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(TopicSinglePageStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_TopicSinglePageStore.refresh');

  @override
  Future<TopicSinglePageStoreData> refresh(int tid, int page) {
    return _$refreshAsyncAction.run(() => super.refresh(tid, page));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
