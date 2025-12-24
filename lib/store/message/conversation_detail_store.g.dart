// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConversationDetailStore on _ConversationDetailStore, Store {
  late final _$stateAtom =
      Atom(name: '_ConversationDetailStore.state', context: context);

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

  late final _$refreshAsyncAction =
      AsyncAction('_ConversationDetailStore.refresh', context: context);

  @override
  Future<ConversationDetailStoreData> refresh(BuildContext context, int? mid) {
    return _$refreshAsyncAction.run(() => super.refresh(context, mid));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('_ConversationDetailStore.loadMore', context: context);

  @override
  Future<ConversationDetailStoreData> loadMore(BuildContext context, int? mid) {
    return _$loadMoreAsyncAction.run(() => super.loadMore(context, mid));
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
