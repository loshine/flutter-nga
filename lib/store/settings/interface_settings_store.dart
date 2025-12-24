import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'interface_settings_store.g.dart';

class InterfaceSettingsStore = _InterfaceSettingsStore
    with _$InterfaceSettingsStore;

enum CustomLineHeight { NORMAL, MEDIUM, LARGE, XLARGE, XXLARGE }

extension LineHeightExtention on CustomLineHeight {
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

  String get nameWithSize {
    return "$name(x $size)";
  }
}

abstract class _InterfaceSettingsStore with Store {
  static const String _prefsName = 'ui';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _settings async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @observable
  var contentSizeMultiple = 1.0;

  @observable
  var titleSizeMultiple = 1.0;

  @observable
  var lineHeight = CustomLineHeight.NORMAL;

  @action
  Future<void> init() async {
    final settings = await _settings;
    contentSizeMultiple =
        settings.getDouble('${_prefsName}_contentSizeMultiple') ?? 1.0;
    titleSizeMultiple =
        settings.getDouble('${_prefsName}_titleSizeMultiple') ?? 1.0;
    lineHeight = await getLineHeight();
  }

  @action
  Future<void> setContentSizeMultiple(double multiple) async {
    contentSizeMultiple = multiple;
    final settings = await _settings;
    await settings.setDouble(
        '${_prefsName}_contentSizeMultiple', contentSizeMultiple);
  }

  @action
  Future<void> setTitleSizeMultiple(double multiple) async {
    titleSizeMultiple = multiple;
    final settings = await _settings;
    await settings.setDouble(
        '${_prefsName}_titleSizeMultiple', titleSizeMultiple);
  }

  @action
  Future<void> setLineHeight(int index) async {
    lineHeight = getLineHeightByIndex(index);
    final settings = await _settings;
    await settings.setInt('${_prefsName}_lineHeight', index);
  }

  Future<CustomLineHeight> getLineHeight() async {
    final settings = await _settings;
    final i = settings.getInt('${_prefsName}_lineHeight') ??
        CustomLineHeight.MEDIUM.index;
    return getLineHeightByIndex(i);
  }

  CustomLineHeight getLineHeightByIndex(int index) {
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
