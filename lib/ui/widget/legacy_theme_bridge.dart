import 'package:material_ui/material_ui.dart';

/// 为尚未迁移的 photo_view、toastification 提供旧版主题。
///
/// flutter_widget_from_html_core 0.17 仍会读取旧版 `Theme` 作为链接默认色、
/// 用 `Tooltip` 包裹带 title 的图片，但前者已被 `NgaHtml` 的样式覆盖，
/// 后者解析器不会产出，因此不再依赖本桥接。
class LegacyThemeBridge extends StatelessWidget {
  const LegacyThemeBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 上游迁移完成后移除；应用自己的组件始终读取 material_ui 主题。
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(child: child);
  }
}
