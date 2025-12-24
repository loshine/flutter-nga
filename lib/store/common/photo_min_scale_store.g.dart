// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_min_scale_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PhotoMinScaleStore on _PhotoMinScaleStore, Store {
  late final _$minScaleAtom =
      Atom(name: '_PhotoMinScaleStore.minScale', context: context);

  @override
  double get minScale {
    _$minScaleAtom.reportRead();
    return super.minScale;
  }

  @override
  set minScale(double value) {
    _$minScaleAtom.reportWrite(value, super.minScale, () {
      super.minScale = value;
    });
  }

  late final _$_PhotoMinScaleStoreActionController =
      ActionController(name: '_PhotoMinScaleStore', context: context);

  @override
  void load(String url, double? screenWidth) {
    final _$actionInfo = _$_PhotoMinScaleStoreActionController.startAction(
        name: '_PhotoMinScaleStore.load');
    try {
      return super.load(url, screenWidth);
    } finally {
      _$_PhotoMinScaleStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
minScale: ${minScale}
    ''';
  }
}
