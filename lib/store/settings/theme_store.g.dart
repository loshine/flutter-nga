// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ThemeStore on _ThemeStore, Store {
  final _$modeAtom = Atom(name: '_ThemeStore.mode');

  @override
  AdaptiveThemeMode? get mode {
    _$modeAtom.reportRead();
    return super.mode;
  }

  @override
  set mode(AdaptiveThemeMode? value) {
    _$modeAtom.reportWrite(value, super.mode, () {
      super.mode = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_ThemeStore.refresh');

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  final _$_ThemeStoreActionController = ActionController(name: '_ThemeStore');

  @override
  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    final _$actionInfo =
        _$_ThemeStoreActionController.startAction(name: '_ThemeStore.update');
    try {
      return super.update(context, adaptiveThemeMode);
    } finally {
      _$_ThemeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mode: ${mode}
    ''';
  }
}
