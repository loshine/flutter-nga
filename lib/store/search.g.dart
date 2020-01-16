// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Search on _Search, Store {
  final _$stateAtom = Atom(name: '_Search.state');

  @override
  SearchState get state {
    _$stateAtom.context.enforceReadPolicy(_$stateAtom);
    _$stateAtom.reportObserved();
    return super.state;
  }

  @override
  set state(SearchState value) {
    _$stateAtom.context.conditionallyRunInAction(() {
      super.state = value;
      _$stateAtom.reportChanged();
    }, _$stateAtom, name: '${_$stateAtom.name}_set');
  }

  final _$_SearchActionController = ActionController(name: '_Search');

  @override
  void checkFirstRadio(int value) {
    final _$actionInfo = _$_SearchActionController.startAction();
    try {
      return super.checkFirstRadio(value);
    } finally {
      _$_SearchActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkTopicRadio(int value) {
    final _$actionInfo = _$_SearchActionController.startAction();
    try {
      return super.checkTopicRadio(value);
    } finally {
      _$_SearchActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkUserRadio(int value) {
    final _$actionInfo = _$_SearchActionController.startAction();
    try {
      return super.checkUserRadio(value);
    } finally {
      _$_SearchActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkContent(bool value) {
    final _$actionInfo = _$_SearchActionController.startAction();
    try {
      return super.checkContent(value);
    } finally {
      _$_SearchActionController.endAction(_$actionInfo);
    }
  }
}
