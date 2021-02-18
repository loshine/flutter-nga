// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicDetailStore on _TopicDetailStore, Store {
  final _$currentPageAtom = Atom(name: '_TopicDetailStore.currentPage');

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  final _$maxPageAtom = Atom(name: '_TopicDetailStore.maxPage');

  @override
  int get maxPage {
    _$maxPageAtom.reportRead();
    return super.maxPage;
  }

  @override
  set maxPage(int value) {
    _$maxPageAtom.reportWrite(value, super.maxPage, () {
      super.maxPage = value;
    });
  }

  final _$_TopicDetailStoreActionController =
      ActionController(name: '_TopicDetailStore');

  @override
  void setMaxPage(int maxPage) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction(
        name: '_TopicDetailStore.setMaxPage');
    try {
      return super.setMaxPage(maxPage);
    } finally {
      _$_TopicDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentPage(int currentPage) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction(
        name: '_TopicDetailStore.setCurrentPage');
    try {
      return super.setCurrentPage(currentPage);
    } finally {
      _$_TopicDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPage: ${currentPage},
maxPage: ${maxPage}
    ''';
  }
}
