// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_forum_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FavouriteForumStore on _FavouriteForumStore, Store {
  final _$isFavouriteAtom = Atom(name: '_FavouriteForumStore.isFavourite');

  @override
  bool get isFavourite {
    _$isFavouriteAtom.context.enforceReadPolicy(_$isFavouriteAtom);
    _$isFavouriteAtom.reportObserved();
    return super.isFavourite;
  }

  @override
  set isFavourite(bool value) {
    _$isFavouriteAtom.context.conditionallyRunInAction(() {
      super.isFavourite = value;
      _$isFavouriteAtom.reportChanged();
    }, _$isFavouriteAtom, name: '${_$isFavouriteAtom.name}_set');
  }

  final _$loadAsyncAction = AsyncAction('load');

  @override
  Future<dynamic> load(int fid, String name) {
    return _$loadAsyncAction.run(() => super.load(fid, name));
  }

  final _$toggleAsyncAction = AsyncAction('toggle');

  @override
  Future<dynamic> toggle(int fid, String name) {
    return _$toggleAsyncAction.run(() => super.toggle(fid, name));
  }
}
