import 'package:mmkv/mmkv.dart';
import 'package:mobx/mobx.dart';

part 'interface_settings_store.g.dart';

class InterfaceSettingsStore = _InterfaceSettingsStore
    with _$InterfaceSettingsStore;

enum CustomLineHeight { normal, medium, large, xlarge, xxlarge }

extension LineHeightExtention on CustomLineHeight {
  double get size {
    switch (this) {
      case CustomLineHeight.normal:
        return 1.2;
      case CustomLineHeight.large:
        return 1.6;
      case CustomLineHeight.xlarge:
        return 1.8;
      case CustomLineHeight.xxlarge:
        return 2.0;
      case CustomLineHeight.medium:
      default:
        return 1.4;
    }
  }

  String get name {
    switch (this) {
      case CustomLineHeight.normal:
        return "紧凑";
      case CustomLineHeight.large:
        return "大杯";
      case CustomLineHeight.xlarge:
        return "加大杯";
      case CustomLineHeight.xxlarge:
        return "超级加倍";
      case CustomLineHeight.medium:
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
  var lineHeight = CustomLineHeight.normal;

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
        defaultValue: CustomLineHeight.medium.index);
    return getLineHeightByIndex(i);
  }

  CustomLineHeight getLineHeightByIndex(int index) {
    switch (index) {
      case 0:
        return CustomLineHeight.normal;
      case 2:
        return CustomLineHeight.large;
      case 3:
        return CustomLineHeight.xlarge;
      case 4:
        return CustomLineHeight.xxlarge;
      case 1:
      default:
        return CustomLineHeight.medium;
    }
  }
}
