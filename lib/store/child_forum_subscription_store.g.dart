// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_forum_subscription_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChildForumSubscriptionStore on _ChildForumSubscriptionStore, Store {
  final _$subscribedAtom =
      Atom(name: '_ChildForumSubscriptionStore.subscribed');

  @override
  bool get subscribed {
    _$subscribedAtom.context.enforceReadPolicy(_$subscribedAtom);
    _$subscribedAtom.reportObserved();
    return super.subscribed;
  }

  @override
  set subscribed(bool value) {
    _$subscribedAtom.context.conditionallyRunInAction(() {
      super.subscribed = value;
      _$subscribedAtom.reportChanged();
    }, _$subscribedAtom, name: '${_$subscribedAtom.name}_set');
  }

  final _$_ChildForumSubscriptionStoreActionController =
      ActionController(name: '_ChildForumSubscriptionStore');

  @override
  void setSubscribed(bool subscribed) {
    final _$actionInfo =
        _$_ChildForumSubscriptionStoreActionController.startAction();
    try {
      return super.setSubscribed(subscribed);
    } finally {
      _$_ChildForumSubscriptionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSubscription(int fid, int parentId) {
    final _$actionInfo =
        _$_ChildForumSubscriptionStoreActionController.startAction();
    try {
      return super.addSubscription(fid, parentId);
    } finally {
      _$_ChildForumSubscriptionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteSubscription(int fid, int parentId) {
    final _$actionInfo =
        _$_ChildForumSubscriptionStoreActionController.startAction();
    try {
      return super.deleteSubscription(fid, parentId);
    } finally {
      _$_ChildForumSubscriptionStoreActionController.endAction(_$actionInfo);
    }
  }
}