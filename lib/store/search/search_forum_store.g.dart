// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_forum_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchForumStore on _SearchForumStore, Store {
  final _$forumsAtom = Atom(name: '_SearchForumStore.forums');

  @override
  List<Forum> get forums {
    _$forumsAtom.reportRead();
    return super.forums;
  }

  @override
  set forums(List<Forum> value) {
    _$forumsAtom.reportWrite(value, super.forums, () {
      super.forums = value;
    });
  }

  final _$searchAsyncAction = AsyncAction('_SearchForumStore.search');

  @override
  Future<List<Forum>> search(String keyword) {
    return _$searchAsyncAction.run(() => super.search(keyword));
  }

  @override
  String toString() {
    return '''
forums: ${forums}
    ''';
  }
}
