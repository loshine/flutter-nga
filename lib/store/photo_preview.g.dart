// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_preview.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PhotoPreview on _PhotoPreview, Store {
  final _$minScaleAtom = Atom(name: '_PhotoPreview.minScale');

  @override
  double get minScale {
    _$minScaleAtom.context.enforceReadPolicy(_$minScaleAtom);
    _$minScaleAtom.reportObserved();
    return super.minScale;
  }

  @override
  set minScale(double value) {
    _$minScaleAtom.context.conditionallyRunInAction(() {
      super.minScale = value;
      _$minScaleAtom.reportChanged();
    }, _$minScaleAtom, name: '${_$minScaleAtom.name}_set');
  }

  final _$_PhotoPreviewActionController =
      ActionController(name: '_PhotoPreview');

  @override
  void load(String url, double screenWidth) {
    final _$actionInfo = _$_PhotoPreviewActionController.startAction();
    try {
      return super.load(url, screenWidth);
    } finally {
      _$_PhotoPreviewActionController.endAction(_$actionInfo);
    }
  }
}
