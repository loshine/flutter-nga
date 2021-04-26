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

  final _$maxFloorAtom = Atom(name: '_TopicDetailStore.maxFloor');

  @override
  int get maxFloor {
    _$maxFloorAtom.reportRead();
    return super.maxFloor;
  }

  @override
  set maxFloor(int value) {
    _$maxFloorAtom.reportWrite(value, super.maxFloor, () {
      super.maxFloor = value;
    });
  }

  final _$topicAtom = Atom(name: '_TopicDetailStore.topic');

  @override
  Topic? get topic {
    _$topicAtom.reportRead();
    return super.topic;
  }

  @override
  set topic(Topic? value) {
    _$topicAtom.reportWrite(value, super.topic, () {
      super.topic = value;
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
  void setMaxFloor(int maxFloor) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction(
        name: '_TopicDetailStore.setMaxFloor');
    try {
      return super.setMaxFloor(maxFloor);
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
  void setTopic(Topic? topic) {
    final _$actionInfo = _$_TopicDetailStoreActionController.startAction(
        name: '_TopicDetailStore.setTopic');
    try {
      return super.setTopic(topic);
    } finally {
      _$_TopicDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPage: ${currentPage},
maxPage: ${maxPage},
maxFloor: ${maxFloor},
topic: ${topic}
    ''';
  }
}
