// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicDetailStore on _TopicDetailStore, Store {
  final _$currentPageAtom = Atom(name: '_TopicDetailStore.currentPage');

  @override
  int get currentPage {
    _$currentPageAtom.context.enforceReadPolicy(_$currentPageAtom);
    _$currentPageAtom.reportObserved();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.context.conditionallyRunInAction(() {
      super.currentPage = value;
      _$currentPageAtom.reportChanged();
    }, _$currentPageAtom, name: '${_$currentPageAtom.name}_set');
  }

  final _$maxPageAtom = Atom(name: '_TopicDetailStore.maxPage');

  @override
  int get maxPage {
    _$maxPageAtom.context.enforceReadPolicy(_$maxPageAtom);
    _$maxPageAtom.reportObserved();
    return super.maxPage;
  }

  @override
  set maxPage(int value) {
    _$maxPageAtom.context.conditionallyRunInAction(() {
      super.maxPage = value;
      _$maxPageAtom.reportChanged();
    }, _$maxPageAtom, name: '${_$maxPageAtom.name}_set');
  }

  final _$_TopicDetailStoreActionController =
      ActionController(name: '_TopicDetailStore');

  @override
  void setMaxPage(int maxPage) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction();
    try {
      return super.setMaxPage(maxPage);
    } finally {
      _$_TopicDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int currentPage) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction();
    try {
      return super.setCurrentPage(currentPage);
    } finally {
      _$_TopicDetailStoreActionController.endAction(_$actionInfo);
    }
  }
}
