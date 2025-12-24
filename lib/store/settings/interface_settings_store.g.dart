// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$InterfaceSettingsStore on _InterfaceSettingsStore, Store {
  late final _$contentSizeMultipleAtom = Atom(
      name: '_InterfaceSettingsStore.contentSizeMultiple', context: context);

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

  late final _$titleSizeMultipleAtom =
      Atom(name: '_InterfaceSettingsStore.titleSizeMultiple', context: context);

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

  late final _$lineHeightAtom =
      Atom(name: '_InterfaceSettingsStore.lineHeight', context: context);

  @override
  CustomLineHeight get lineHeight {
    _$lineHeightAtom.reportRead();
    return super.lineHeight;
  }

  @override
  set lineHeight(CustomLineHeight value) {
    _$lineHeightAtom.reportWrite(value, super.lineHeight, () {
      super.lineHeight = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_InterfaceSettingsStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$setContentSizeMultipleAsyncAction = AsyncAction(
      '_InterfaceSettingsStore.setContentSizeMultiple',
      context: context);

  @override
  Future<void> setContentSizeMultiple(double multiple) {
    return _$setContentSizeMultipleAsyncAction
        .run(() => super.setContentSizeMultiple(multiple));
  }

  late final _$setTitleSizeMultipleAsyncAction = AsyncAction(
      '_InterfaceSettingsStore.setTitleSizeMultiple',
      context: context);

  @override
  Future<void> setTitleSizeMultiple(double multiple) {
    return _$setTitleSizeMultipleAsyncAction
        .run(() => super.setTitleSizeMultiple(multiple));
  }

  late final _$setLineHeightAsyncAction =
      AsyncAction('_InterfaceSettingsStore.setLineHeight', context: context);

  @override
  Future<void> setLineHeight(int index) {
    return _$setLineHeightAsyncAction.run(() => super.setLineHeight(index));
  }

  @override
  String toString() {
    return '''
contentSizeMultiple: ${contentSizeMultiple},
titleSizeMultiple: ${titleSizeMultiple},
lineHeight: ${lineHeight}
    ''';
  }
}
