// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$InterfaceSettingsStore on _InterfaceSettingsStore, Store {
  final _$contentSizeMultipleAtom =
      Atom(name: '_InterfaceSettingsStore.contentSizeMultiple');

  @override
  double get contentSizeMultiple {
    _$contentSizeMultipleAtom.reportRead();
    return super.contentSizeMultiple;
  }

  @override
  set contentSizeMultiple(double value) {
    _$contentSizeMultipleAtom.reportWrite(value, super.contentSizeMultiple, () {
      super.contentSizeMultiple = value;
    });
  }

  final _$titleSizeMultipleAtom =
      Atom(name: '_InterfaceSettingsStore.titleSizeMultiple');

  @override
  double get titleSizeMultiple {
    _$titleSizeMultipleAtom.reportRead();
    return super.titleSizeMultiple;
  }

  @override
  set titleSizeMultiple(double value) {
    _$titleSizeMultipleAtom.reportWrite(value, super.titleSizeMultiple, () {
      super.titleSizeMultiple = value;
    });
  }

  final _$_InterfaceSettingsStoreActionController =
      ActionController(name: '_InterfaceSettingsStore');

  @override
  void setContentSizeMultiple(double multiple) {
    final _$actionInfo = _$_InterfaceSettingsStoreActionController.startAction(
        name: '_InterfaceSettingsStore.setContentSizeMultiple');
    try {
      return super.setContentSizeMultiple(multiple);
    } finally {
      _$_InterfaceSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTitleSizeMultiple(double multiple) {
    final _$actionInfo = _$_InterfaceSettingsStoreActionController.startAction(
        name: '_InterfaceSettingsStore.setTitleSizeMultiple');
    try {
      return super.setTitleSizeMultiple(multiple);
    } finally {
      _$_InterfaceSettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
contentSizeMultiple: ${contentSizeMultiple},
titleSizeMultiple: ${titleSizeMultiple}
    ''';
  }
}
