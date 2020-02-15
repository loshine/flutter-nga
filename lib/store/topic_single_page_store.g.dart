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
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(TopicSinglePageStoreData value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$refreshAsyncAction = AsyncAction('refresh');

  @override
  Future<TopicSinglePageStoreData> refresh(int tid, int page) {
    return _$refreshAsyncAction.run(() => super.refresh(tid, page));
  }
}
