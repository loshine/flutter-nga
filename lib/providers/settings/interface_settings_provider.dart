import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';

enum CustomLineHeight { NORMAL, MEDIUM, LARGE, XLARGE, XXLARGE }

extension LineHeightExtension on CustomLineHeight {
  double get size {
    switch (this) {
      case CustomLineHeight.NORMAL:
        return 1.2;
      case CustomLineHeight.LARGE:
        return 1.6;
      case CustomLineHeight.XLARGE:
        return 1.8;
      case CustomLineHeight.XXLARGE:
        return 2.0;
      case CustomLineHeight.MEDIUM:
        return 1.4;
    }
  }

  String get name {
    switch (this) {
      case CustomLineHeight.NORMAL:
        return "紧凑";
      case CustomLineHeight.LARGE:
        return "大杯";
      case CustomLineHeight.XLARGE:
        return "加大杯";
      case CustomLineHeight.XXLARGE:
        return "超级加倍";
      case CustomLineHeight.MEDIUM:
        return "Material Design";
    }
  }

  String get nameWithSize => "$name(x $size)";
}

class InterfaceSettingsState {
  final double contentSizeMultiple;
  final double titleSizeMultiple;
  final CustomLineHeight lineHeight;

  const InterfaceSettingsState({
    this.contentSizeMultiple = 1.0,
    this.titleSizeMultiple = 1.0,
    this.lineHeight = CustomLineHeight.MEDIUM,
  });

  InterfaceSettingsState copyWith({
    double? contentSizeMultiple,
    double? titleSizeMultiple,
    CustomLineHeight? lineHeight,
  }) {
    return InterfaceSettingsState(
      contentSizeMultiple: contentSizeMultiple ?? this.contentSizeMultiple,
      titleSizeMultiple: titleSizeMultiple ?? this.titleSizeMultiple,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class InterfaceSettingsNotifier extends Notifier<InterfaceSettingsState> {
  SharedPreferencesWithCache? _prefs;

  @override
  InterfaceSettingsState build() => const InterfaceSettingsState();

  Future<SharedPreferencesWithCache> get _settings async {
    _prefs ??= await AppPreferences.instance();
    return _prefs!;
  }

  Future<void> init() async {
    final settings = await _settings;
    final contentSize =
        settings.getDouble(PrefsKeys.uiContentSizeMultiple) ?? 1.0;
    final titleSize = settings.getDouble(PrefsKeys.uiTitleSizeMultiple) ?? 1.0;
    final lineHeightIndex =
        settings.getInt(PrefsKeys.uiLineHeight) ??
        CustomLineHeight.MEDIUM.index;

    state = InterfaceSettingsState(
      contentSizeMultiple: contentSize,
      titleSizeMultiple: titleSize,
      lineHeight: _getLineHeightByIndex(lineHeightIndex),
    );
  }

  Future<void> setContentSizeMultiple(double multiple) async {
    state = state.copyWith(contentSizeMultiple: multiple);
    final settings = await _settings;
    await settings.setDouble(PrefsKeys.uiContentSizeMultiple, multiple);
  }

  Future<void> setTitleSizeMultiple(double multiple) async {
    state = state.copyWith(titleSizeMultiple: multiple);
    final settings = await _settings;
    await settings.setDouble(PrefsKeys.uiTitleSizeMultiple, multiple);
  }

  Future<void> setLineHeight(int index) async {
    final lineHeight = _getLineHeightByIndex(index);
    state = state.copyWith(lineHeight: lineHeight);
    final settings = await _settings;
    await settings.setInt(PrefsKeys.uiLineHeight, index);
  }

  CustomLineHeight _getLineHeightByIndex(int index) {
    switch (index) {
      case 0:
        return CustomLineHeight.NORMAL;
      case 2:
        return CustomLineHeight.LARGE;
      case 3:
        return CustomLineHeight.XLARGE;
      case 4:
        return CustomLineHeight.XXLARGE;
      case 1:
      default:
        return CustomLineHeight.MEDIUM;
    }
  }
}

final interfaceSettingsProvider =
    NotifierProvider<InterfaceSettingsNotifier, InterfaceSettingsState>(
      InterfaceSettingsNotifier.new,
    );
