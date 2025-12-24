// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_mode_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DisplayModeStore on _DisplayModeStore, Store {
  late final _$modesAtom =
      Atom(name: '_DisplayModeStore.modes', context: context);

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

  late final _$activeAtom =
      Atom(name: '_DisplayModeStore.active', context: context);

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

  late final _$preferredAtom =
      Atom(name: '_DisplayModeStore.preferred', context: context);

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

  late final _$refreshAsyncAction =
      AsyncAction('_DisplayModeStore.refresh', context: context);

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  late final _$setHighRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.setHighRefreshRate', context: context);

  @override
  Future<void> setHighRefreshRate() {
    return _$setHighRefreshRateAsyncAction
        .run(() => super.setHighRefreshRate());
  }

  late final _$setLowRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.setLowRefreshRate', context: context);

  @override
  Future<void> setLowRefreshRate() {
    return _$setLowRefreshRateAsyncAction.run(() => super.setLowRefreshRate());
  }

  late final _$setPreferredModeAsyncAction =
      AsyncAction('_DisplayModeStore.setPreferredMode', context: context);

  @override
  Future<void> setPreferredMode(DisplayMode mode) {
    return _$setPreferredModeAsyncAction
        .run(() => super.setPreferredMode(mode));
  }

  late final _$isHighRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.isHighRefreshRate', context: context);

  @override
  Future<bool> isHighRefreshRate() {
    return _$isHighRefreshRateAsyncAction.run(() => super.isHighRefreshRate());
  }

  late final _$isLowRefreshRateAsyncAction =
      AsyncAction('_DisplayModeStore.isLowRefreshRate', context: context);

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
