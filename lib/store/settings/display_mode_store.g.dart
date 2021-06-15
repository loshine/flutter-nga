// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_mode_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DisplayModeStore on _DisplayModeStore, Store {
  final _$modesAtom = Atom(name: '_DisplayModeStore.modes');

  @override
  List<DisplayMode> get modes {
    _$modesAtom.reportRead();
    return super.modes;
  }

  @override
  set modes(List<DisplayMode> value) {
    _$modesAtom.reportWrite(value, super.modes, () {
      super.modes = value;
    });
  }

  final _$activeAtom = Atom(name: '_DisplayModeStore.active');

  @override
  DisplayMode? get active {
    _$activeAtom.reportRead();
    return super.active;
  }

  @override
  set active(DisplayMode? value) {
    _$activeAtom.reportWrite(value, super.active, () {
      super.active = value;
    });
  }

  final _$preferredAtom = Atom(name: '_DisplayModeStore.preferred');

  @override
  DisplayMode? get preferred {
    _$preferredAtom.reportRead();
    return super.preferred;
  }

  @override
  set preferred(DisplayMode? value) {
    _$preferredAtom.reportWrite(value, super.preferred, () {
      super.preferred = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_DisplayModeStore.refresh');

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$setHighRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.setHighRefreshRate');

  @override
  Future<void> setHighRefreshRate() {
    return _$setHighRefreshRateAsyncAction
        .run(() => super.setHighRefreshRate());
  }

  final _$setLowRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.setLowRefreshRate');

  @override
  Future<void> setLowRefreshRate() {
    return _$setLowRefreshRateAsyncAction.run(() => super.setLowRefreshRate());
  }

  final _$setPreferredModeAsyncAction =
      AsyncAction('_DisplayModeStore.setPreferredMode');

  @override
  Future<void> setPreferredMode(DisplayMode mode) {
    return _$setPreferredModeAsyncAction
        .run(() => super.setPreferredMode(mode));
  }

  final _$isHighRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.isHighRefreshRate');

  @override
  Future<bool> isHighRefreshRate() {
    return _$isHighRefreshRateAsyncAction.run(() => super.isHighRefreshRate());
  }

  final _$isLowRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.isLowRefreshRate');

  @override
  Future<bool> isLowRefreshRate() {
    return _$isLowRefreshRateAsyncAction.run(() => super.isLowRefreshRate());
  }

  @override
  String toString() {
    return '''
modes: ${modes},
active: ${active},
preferred: ${preferred}
    ''';
  }
}
