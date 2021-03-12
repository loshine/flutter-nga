// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ConversationDetailStore on _ConversationDetailStore, Store {
  final _$stateAtom = Atom(name: '_ConversationDetailStore.state');

  @override
  ConversationDetailStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(ConversationDetailStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_ConversationDetailStore.refresh');

  @override
  Future<ConversationDetailStoreData> refresh(int? mid) {
    return _$refreshAsyncAction.run(() => super.refresh(mid));
  }

  final _$loadMoreAsyncAction =
      AsyncAction('_ConversationDetailStore.loadMore');

  @override
  Future<ConversationDetailStoreData> loadMore(int? mid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(mid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
