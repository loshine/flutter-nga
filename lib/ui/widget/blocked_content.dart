import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 按屏蔽模式包装楼层 / 评论：折叠与涂抹可点击查看，隐藏不占位，淡化降低透明度。
/// 删除线模式需要作用到文字本身，由 [child] 自行处理，这里原样展示。
class BlockedContent extends StatefulWidget {
  const BlockedContent({
    super.key,
    required this.mode,
    required this.child,
  });

  /// null 表示未被屏蔽
  final BlockMode? mode;
  final Widget child;

  @override
  State<BlockedContent> createState() => _BlockedContentState();
}

class _BlockedContentState extends State<BlockedContent> {
  bool _revealed = false;

  @override
  void didUpdateWidget(BlockedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (_revealed ? null : widget.mode) {
      BlockMode.GONE => const SizedBox.shrink(),
      BlockMode.COLLAPSE => _buildMask(colorScheme, "折叠的屏蔽内容，点击展开"),
      BlockMode.ALPHA => Opacity(opacity: 0.38, child: widget.child),
      BlockMode.PAINT => Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: _buildMask(colorScheme, "已涂抹的屏蔽内容，点击查看"),
            ),
          ],
        ),
      _ => widget.child,
    };
  }

  Widget _buildMask(ColorScheme colorScheme, String hint) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => setState(() => _revealed = true),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(Dimen.spacingL),
          child: Text(
            hint,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
