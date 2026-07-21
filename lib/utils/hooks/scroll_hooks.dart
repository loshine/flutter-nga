import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Tracks FAB visibility from list scroll direction.
///
/// - Scroll reverse (content up) → hide
/// - Scroll forward (content down) → show
({
  bool visible,
  bool Function(UserScrollNotification notification) onNotification,
}) useScrollFabVisibility({bool initialVisible = true}) {
  final visible = useState(initialVisible);

  bool onNotification(UserScrollNotification notification) {
    final direction = notification.direction;
    if (direction == ScrollDirection.reverse) {
      if (visible.value) visible.value = false;
    } else if (direction == ScrollDirection.forward) {
      if (!visible.value) visible.value = true;
    }
    return false;
  }

  return (visible: visible.value, onNotification: onNotification);
}
