// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_forum_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FavouriteForumStore on _FavouriteForumStore, Store {
  late final _$isFavouriteAtom =
      Atom(name: '_FavouriteForumStore.isFavourite', context: context);

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

  late final _$loadAsyncAction =
      AsyncAction('_FavouriteForumStore.load', context: context);

  @override
  Future<dynamic> load(int fid, String? name) {
    return _$loadAsyncAction.run(() => super.load(fid, name));
  }

  late final _$toggleAsyncAction =
      AsyncAction('_FavouriteForumStore.toggle', context: context);

  @override
  Future<dynamic> toggle(int fid, String? name, int? type) {
    return _$toggleAsyncAction.run(() => super.toggle(fid, name, type));
  }

  @override
  String toString() {
    return '''
isFavourite: ${isFavourite}
    ''';
  }
}
