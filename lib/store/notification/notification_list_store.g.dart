// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NotificationListStore on _NotificationListStore, Store {
  final _$stateAtom = Atom(name: '_NotificationListStore.state');

  @override
  NotificationInfoListData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(NotificationInfoListData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_NotificationListStore.refresh');

  @override
  Future<NotificationInfoListData> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
