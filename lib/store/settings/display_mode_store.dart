import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:mobx/mobx.dart';

part 'display_mode_store.g.dart';

class DisplayModeStore = _DisplayModeStore with _$DisplayModeStore;

abstract class _DisplayModeStore with Store {
  @observable
  List<DisplayMode> modes = <DisplayMode>[];
  @observable
  DisplayMode? active;
  @observable
  DisplayMode? preferred;

  String get modeName {
    if (active == null) return "标准模式";
    var highest = active!;
    for (final DisplayMode mode in modes) {
      if (mode.height == highest.height &&
          mode.width == highest.width &&
          mode.refreshRate > highest.refreshRate) {
        highest = mode;
      }
    }
    if (highest == active) {
      return "高帧率模式";
    } else {
      return "标准模式";
    }
  }

  @action
  Future<void> refresh() async {
    try {
      modes = await FlutterDisplayMode.supported;
      modes.forEach(print);

      /// On OnePlus 7 Pro:
      /// #1 1080x2340 @ 60Hz
      /// #2 1080x2340 @ 90Hz
      /// #3 1440x3120 @ 90Hz
      /// #4 1440x3120 @ 60Hz
      /// On OnePlus 8 Pro:
      /// #1 1080x2376 @ 60Hz
      /// #2 1440x3168 @ 120Hz
      /// #3 1440x3168 @ 60Hz
      /// #4 1080x2376 @ 120Hz
    } on PlatformException catch (e) {
      print(e);

      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }
    preferred = await FlutterDisplayMode.preferred;
    active = await FlutterDisplayMode.active;

    debugPrint("preferred:$preferred \n");
    debugPrint("active:$active \n");
  }

  @action
  Future<void> setHighRefreshRate() async {
    return await FlutterDisplayMode.setHighRefreshRate();
  }

  @action
  Future<void> setLowRefreshRate() async {
    return await FlutterDisplayMode.setLowRefreshRate();
  }

  @action
  Future<void> setPreferredMode(DisplayMode mode) async {
    return await FlutterDisplayMode.setPreferredMode(mode);
  }

  @action
  Future<bool> isHighRefreshRate() async {
    return preferred == await getHighRefreshRate();
  }

  @action
  Future<bool> isLowRefreshRate() async {
    return preferred == await getLowRefreshRate();
  }

  Future<DisplayMode> getHighRefreshRate() async {
    DisplayMode newMode = active ?? await FlutterDisplayMode.active;
    for (final DisplayMode mode in modes) {
      if (mode.height == newMode.height &&
          mode.width == newMode.width &&
          mode.refreshRate > newMode.refreshRate) {
        newMode = mode;
      }
    }

    return newMode;
  }

  Future<DisplayMode> getLowRefreshRate() async {
    DisplayMode newMode = active ?? await FlutterDisplayMode.active;
    for (final DisplayMode mode in modes) {
      if (mode.height == newMode.height &&
          mode.width == newMode.width &&
          mode.refreshRate < newMode.refreshRate) {
        newMode = mode;
      }
    }

    return newMode;
  }
}
