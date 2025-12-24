// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_forum_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavouriteForumListStore on _FavouriteForumListStore, Store {
  late final _$listAtom =
      Atom(name: '_FavouriteForumListStore.list', context: context);

  @override
  List<Forum> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(List<Forum> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  late final _$addAsyncAction =
      AsyncAction('_FavouriteForumListStore.add', context: context);

  @override
  Future<void> add(int fid, String name) {
    return _$addAsyncAction.run(() => super.add(fid, name));
  }

  late final _$deleteAsyncAction =
      AsyncAction('_FavouriteForumListStore.delete', context: context);

  @override
  Future<void> delete(int fid) {
    return _$deleteAsyncAction.run(() => super.delete(fid));
  }

  late final _$_FavouriteForumListStoreActionController =
      ActionController(name: '_FavouriteForumListStore', context: context);

  @override
  void refresh() {
    final _$actionInfo = _$_FavouriteForumListStoreActionController.startAction(
        name: '_FavouriteForumListStore.refresh');
    try {
      return super.refresh();
    } finally {
      _$_FavouriteForumListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
list: ${list}
    ''';
  }
}
