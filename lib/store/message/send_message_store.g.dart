// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SendMessageStore on _SendMessageStore, Store {
  final _$contactsAtom = Atom(name: '_SendMessageStore.contacts');

  @override
  List<String> get contacts {
    _$contactsAtom.reportRead();
    return super.contacts;
  }

  @override
  set contacts(List<String> value) {
    _$contactsAtom.reportWrite(value, super.contacts, () {
      super.contacts = value;
    });
  }

  final _$_SendMessageStoreActionController =
      ActionController(name: '_SendMessageStore');

  @override
  dynamic add(String contact) {
    final _$actionInfo = _$_SendMessageStoreActionController.startAction(
        name: '_SendMessageStore.add');
    try {
      return super.add(contact);
    } finally {
      _$_SendMessageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic remove(String contact) {
    final _$actionInfo = _$_SendMessageStoreActionController.startAction(
        name: '_SendMessageStore.remove');
    try {
      return super.remove(contact);
    } finally {
      _$_SendMessageStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
contacts: ${contacts}
    ''';
  }
}
