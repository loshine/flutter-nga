// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_forum_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FavouriteForumStore on _FavouriteForumStore, Store {
  final _$isFavouriteAtom = Atom(name: '_FavouriteForumStore.isFavourite');

  @override
  bool get isFavourite {
    _$isFavouriteAtom.reportRead();
    return super.isFavourite;
  }

  @override
  set isFavourite(bool value) {
    _$isFavouriteAtom.reportWrite(value, super.isFavourite, () {
      super.isFavourite = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_FavouriteForumStore.load');

  @override
  Future<dynamic> load(int fid, String name) {
    return _$loadAsyncAction.run(() => super.load(fid, name));
  }

  final _$toggleAsyncAction = AsyncAction('_FavouriteForumStore.toggle');

  @override
  Future<dynamic> toggle(int fid, String name) {
    return _$toggleAsyncAction.run(() => super.toggle(fid, name));
  }

  @override
  String toString() {
    return '''
isFavourite: ${isFavourite}
    ''';
  }
}
