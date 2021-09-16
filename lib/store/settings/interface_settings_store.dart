import 'package:mmkv/mmkv.dart';
import 'package:mobx/mobx.dart';

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
      default:
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
      default:
        return "Material Design";
    }
  }

  String get nameWithSize {
    return "$name(x $size)";
  }
}

abstract class _InterfaceSettingsStore with Store {
  final settings = MMKV("ui");

  @observable
  var contentSizeMultiple = 1.0;

  @observable
  var titleSizeMultiple = 1.0;

  @observable
  var lineHeight = CustomLineHeight.NORMAL;

  @action
  void init() {
    contentSizeMultiple =
        settings.decodeDouble("contentSizeMultiple", defaultValue: 1.0);
    titleSizeMultiple =
        settings.decodeDouble("titleSizeMultiple", defaultValue: 1.0);
    lineHeight = getLineHeight();
  }

  @action
  void setContentSizeMultiple(double multiple) {
    contentSizeMultiple = multiple;
    settings.encodeDouble("contentSizeMultiple", contentSizeMultiple);
  }

  @action
  void setTitleSizeMultiple(double multiple) {
    titleSizeMultiple = multiple;
    settings.encodeDouble("titleSizeMultiple", titleSizeMultiple);
  }

  @action
  void setLineHeight(int index) {
    lineHeight = getLineHeightByIndex(index);
    settings.encodeInt("lineHeight", index);
  }

  CustomLineHeight getLineHeight() {
    final i = settings.decodeInt("lineHeight",
        defaultValue: CustomLineHeight.MEDIUM.index);
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
