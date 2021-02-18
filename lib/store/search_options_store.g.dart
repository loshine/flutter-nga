// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_options_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchOptionsStore on _SearchOptionsStore, Store {
  final _$stateAtom = Atom(name: '_SearchOptionsStore.state');

  @override
  SearchStoreData get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(SearchStoreData value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$_SearchOptionsStoreActionController =
      ActionController(name: '_SearchOptionsStore');

  @override
  void checkFirstRadio(int value) {
    final _$actionInfo = _$_SearchOptionsStoreActionController.startAction(
        name: '_SearchOptionsStore.checkFirstRadio');
    try {
      return super.checkFirstRadio(value);
    } finally {
      _$_SearchOptionsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkTopicRadio(int value) {
    final _$actionInfo = _$_SearchOptionsStoreActionController.startAction(
        name: '_SearchOptionsStore.checkTopicRadio');
    try {
      return super.checkTopicRadio(value);
    } finally {
      _$_SearchOptionsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkUserRadio(int value) {
    final _$actionInfo = _$_SearchOptionsStoreActionController.startAction(
        name: '_SearchOptionsStore.checkUserRadio');
    try {
      return super.checkUserRadio(value);
    } finally {
      _$_SearchOptionsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void checkContent(bool value) {
    final _$actionInfo = _$_SearchOptionsStoreActionController.startAction(
        name: '_SearchOptionsStore.checkContent');
    try {
      return super.checkContent(value);
    } finally {
      _$_SearchOptionsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state}
    ''';
  }
}
