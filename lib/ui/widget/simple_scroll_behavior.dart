import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoScrollbar;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class SimpleScrollBehavior extends ScrollBehavior {
  const SimpleScrollBehavior({this.isAppleStyle = false});

  final bool isAppleStyle;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (isAppleStyle) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Apple 桌面形态按 macOS HIG 显示细滚动条（仅垂直主列表，跳过水平 TabBar）；
    // 其余场景保持无滚动条的简洁观感。
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    if (isAppleStyle && isDesktop && details.direction == AxisDirection.down) {
      return CupertinoScrollbar(controller: details.controller, child: child);
    }
    return child;
  }

  @override
  bool shouldNotify(covariant SimpleScrollBehavior oldDelegate) {
    return isAppleStyle != oldDelegate.isAppleStyle;
  }
}
