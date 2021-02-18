// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ConversationListStore on _ConversationListStore, Store {
  final _$stateAtom = Atom(name: '_ConversationListStore.state');

  @override
  ConversationListStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(ConversationListStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_ConversationListStore.refresh');

  @override
  Future<ConversationListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$loadMoreAsyncAction = AsyncAction('_ConversationListStore.loadMore');

  @override
  Future<ConversationListStoreData> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
