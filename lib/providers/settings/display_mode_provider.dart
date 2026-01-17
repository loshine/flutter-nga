import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class DisplayModeState {
  final List<DisplayMode> modes;
  final DisplayMode? active;
  final DisplayMode? preferred;

  DisplayModeState({
    this.modes = const [],
    this.active,
    this.preferred,
  });

  String get modeName => "标准模式";

  DisplayModeState copyWith({
    List<DisplayMode>? modes,
    DisplayMode? active,
    DisplayMode? preferred,
  }) {
    return DisplayModeState(
      modes: modes ?? this.modes,
      active: active ?? this.active,
      preferred: preferred ?? this.preferred,
    );
  }
}

class DisplayModeNotifier extends Notifier<DisplayModeState> {
  @override
  DisplayModeState build() => DisplayModeState();

  Future<void> refresh() async {
    debugPrint('DisplayModeNotifier.refresh() - 鸿蒙系统待实现');
  }

  Future<void> setHighRefreshRate() async {}

  Future<void> setLowRefreshRate() async {}

  Future<void> setPreferredMode(DisplayMode mode) async {}

  Future<bool> isHighRefreshRate() async => false;

  Future<bool> isLowRefreshRate() async => false;

  Future<DisplayMode> getHighRefreshRate() async =>
      DisplayMode(0, 0, 0, 60.0);

  Future<DisplayMode> getLowRefreshRate() async =>
      DisplayMode(0, 0, 0, 60.0);
}

final displayModeProvider =
    NotifierProvider<DisplayModeNotifier, DisplayModeState>(DisplayModeNotifier.new);
