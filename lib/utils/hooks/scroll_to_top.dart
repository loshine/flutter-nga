import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_nga/utils/motion.dart';

/// 「回到顶部」信号：页面在点击标题 / 双击导航项时 [fire]，列表收到后滚回顶部。
class ScrollToTopSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// 把 [controller] 滚回顶部。离顶部很远时先跳到较近的位置再动画，
/// 避免长列表动画途中构建大量列表项。
Future<void> scrollToTop(ScrollController controller) async {
  if (!controller.hasClients) return;
  final position = controller.position;
  final nearby = position.viewportDimension * 2;
  if (position.pixels > nearby) controller.jumpTo(nearby);
  await controller.animateTo(
    0,
    duration: Motion.durationMedium4,
    curve: Motion.emphasized,
  );
}

/// 创建随 hook 释放的 [ScrollController]，[signal] 触发时滚回顶部。
ScrollController useScrollToTopController(ScrollToTopSignal? signal) {
  final controller = useScrollController();
  useEffect(() {
    if (signal == null) return null;
    void listener() => scrollToTop(controller);
    signal.addListener(listener);
    return () => signal.removeListener(listener);
  }, [signal, controller]);
  return controller;
}

/// 为每个 Tab 准备一个信号，[length] 变化时重建。
List<ScrollToTopSignal> useScrollToTopSignals(int length) {
  final signals = useMemoized(
    () => List.generate(length, (_) => ScrollToTopSignal()),
    [length],
  );
  useEffect(() {
    return () {
      for (final signal in signals) {
        signal.dispose();
      }
    };
  }, [signals]);
  return signals;
}

/// 识别「连续两次点击同一个已选中的导航项」。
///
/// 每次点击已选中项时调用 [tap]，在 [interval] 内第二次点击返回 true；
/// 切换到其他项时调用 [reset]。
class DoubleTapDetector {
  DoubleTapDetector({
    this.interval = const Duration(milliseconds: 500),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration interval;
  final DateTime Function() _clock;
  DateTime? _lastTap;

  bool tap() {
    final now = _clock();
    final last = _lastTap;
    if (last != null && now.difference(last) <= interval) {
      _lastTap = null;
      return true;
    }
    _lastTap = now;
    return false;
  }

  void reset() => _lastTap = null;
}
