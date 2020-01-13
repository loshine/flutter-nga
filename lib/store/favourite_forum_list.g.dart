// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_forum_list.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FavouriteForumList on _FavouriteForumList, Store {
  final _$listAtom = Atom(name: '_FavouriteForumList.list');

  @override
  List<Forum> get list {
    _$listAtom.context.enforceReadPolicy(_$listAtom);
    _$listAtom.reportObserved();
    return super.list;
  }

  @override
  set list(List<Forum> value) {
    _$listAtom.context.conditionallyRunInAction(() {
      super.list = value;
      _$listAtom.reportChanged();
    }, _$listAtom, name: '${_$listAtom.name}_set');
  }

  final _$_FavouriteForumListActionController =
      ActionController(name: '_FavouriteForumList');

  @override
  void refresh() {
    final _$actionInfo = _$_FavouriteForumListActionController.startAction();
    try {
      return super.refresh();
    } finally {
      _$_FavouriteForumListActionController.endAction(_$actionInfo);
    }
  }
}
