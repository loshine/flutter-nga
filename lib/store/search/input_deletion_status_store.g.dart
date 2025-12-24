// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_deletion_status_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$InputDeletionStatusStore on _InputDeletionStatusStore, Store {
  late final _$visibleAtom =
      Atom(name: '_InputDeletionStatusStore.visible', context: context);

  @override
  bool get visible {
    _$visibleAtom.reportRead();
    return super.visible;
  }

  @override
  set visible(bool value) {
    _$visibleAtom.reportWrite(value, super.visible, () {
      super.visible = value;
    });
  }

  late final _$_InputDeletionStatusStoreActionController =
      ActionController(name: '_InputDeletionStatusStore', context: context);

  @override
  void setVisible(bool val) {
    final _$actionInfo = _$_InputDeletionStatusStoreActionController
        .startAction(name: '_InputDeletionStatusStore.setVisible');
    try {
      return super.setVisible(val);
    } finally {
      _$_InputDeletionStatusStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
visible: ${visible}
    ''';
  }
}
