// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConversationListStore on _ConversationListStore, Store {
  late final _$stateAtom =
      Atom(name: '_ConversationListStore.state', context: context);

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

  late final _$refreshAsyncAction =
      AsyncAction('_ConversationListStore.refresh', context: context);

  @override
  Future<ConversationListStoreData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_ConversationListStore.loadMore', context: context);

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
