import 'package:material_ui/material_ui.dart';

/// 为尚未迁移的 flutter_html、photo_view、toastification 提供旧版主题。
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
