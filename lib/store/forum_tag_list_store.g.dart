// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_tag_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ForumTagListStore on _ForumTagListStore, Store {
  final _$tagListAtom = Atom(name: '_ForumTagListStore.tagList');

  @override
  List<TopicTag> get tagList {
    _$tagListAtom.reportRead();
    return super.tagList;
  }

  @override
  set tagList(List<TopicTag> value) {
    _$tagListAtom.reportWrite(value, super.tagList, () {
      super.tagList = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_ForumTagListStore.load');

  @override
  Future<List<TopicTag>> load(int fid) {
    return _$loadAsyncAction.run(() => super.load(fid));
  }

  final _$_ForumTagListStoreActionController =
      ActionController(name: '_ForumTagListStore');

  @override
  void setList(List<TopicTag> list) {
    final _$actionInfo = _$_ForumTagListStoreActionController.startAction(
        name: '_ForumTagListStore.setList');
    try {
      return super.setList(list);
    } finally {
      _$_ForumTagListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tagList: ${tagList}
    ''';
  }
}
