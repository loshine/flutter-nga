// TODO: flutter_displaymode 已移除，鸿蒙系统不支持
// 该文件内容已注释，待后续实现鸿蒙系统的显示模式控制

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'display_mode_store.g.dart';

// 空的 DisplayMode 占位类
class DisplayMode {
  final int id;
  final int width;
  final int height;
  final double refreshRate;

  DisplayMode(this.id, this.width, this.height, this.refreshRate);

  @override
  String toString() =>
      'DisplayMode(id: $id, ${width}x$height @ ${refreshRate}Hz)';
}

class DisplayModeStore = _DisplayModeStore with _$DisplayModeStore;

abstract class _DisplayModeStore with Store {
  @observable
  List<DisplayMode> modes = <DisplayMode>[];
  @observable
  DisplayMode? active;
  @observable
  DisplayMode? preferred;

  String get modeName {
    // TODO: 鸿蒙系统显示模式待实现
    return "标准模式";
  }

  @action
  Future<void> refresh() async {
    // TODO: 鸿蒙系统显示模式待实现
    debugPrint('DisplayModeStore.refresh() - 鸿蒙系统待实现');
  }

  @action
  Future<void> setHighRefreshRate() async {
    // TODO: 鸿蒙系统显示模式待实现
  }

  @action
  Future<void> setLowRefreshRate() async {
    // TODO: 鸿蒙系统显示模式待实现
  }

  @action
  Future<void> setPreferredMode(DisplayMode mode) async {
    // TODO: 鸿蒙系统显示模式待实现
  }

  @action
  Future<bool> isHighRefreshRate() async {
    return false;
  }

  @action
  Future<bool> isLowRefreshRate() async {
    return false;
  }

  Future<DisplayMode> getHighRefreshRate() async {
    return DisplayMode(0, 0, 0, 60.0);
  }

  Future<DisplayMode> getLowRefreshRate() async {
    return DisplayMode(0, 0, 0, 60.0);
  }
}
