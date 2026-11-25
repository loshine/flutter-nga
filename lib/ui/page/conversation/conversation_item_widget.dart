import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';

class ConversationItemWidget extends StatelessWidget {
  final Conversation? conversation;

  /// 从对话详情返回且已退出对话时回调。
  final VoidCallback? onLeft;

  /// 自定义点击回调（如大屏双栏时在右侧打开对话详情）
  final VoidCallback? onTap;

  /// 是否在大屏双栏列表中处于选中状态
  final bool selected;

  const ConversationItemWidget({
    super.key,
    this.conversation,
    this.onLeft,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;
    final isMac = context.isMacDesktopAppleStyle;

    Future<void> handleTap() async {
      if (onTap != null) {
        onTap!();
        return;
      }
      final left = await Routes.navigateTo(
        context,
        "${Routes.CONVERSATION_DETAIL}?mid=${conversation!.mid}",
      );
      if (left == true) onLeft?.call();
    }

    if (isApple) {
      final selectedBg = colorScheme.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.14,
      );
      final metaColor = colorScheme.onSurfaceVariant;
      final metaSize = isMac ? 11.5 : 12.0;

      final rowBody = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMac ? 12 : 16,
          vertical: isMac ? 9 : 11,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: conversation!.subject,
                style: TextStyle(
                  fontSize: isMac ? 13.5 : 15,
                  height: 1.35,
                  fontWeight: conversation!.isUnread
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: ' (${conversation!.posts})',
                    style: TextStyle(
                      fontSize: isMac ? 12.5 : 14,
                      fontWeight: FontWeight.w400,
                      color: metaColor,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMac ? 5 : 6),
            Row(
              children: [
                Icon(
                  CupertinoIcons.person_2,
                  color: metaColor,
                  size: isMac ? 12 : 13,
                ),
                const SizedBox(width: 4),
                if (conversation!.isMultiUser) ...[
                  Text(
                    '[多人]',
                    style: TextStyle(fontSize: metaSize, color: metaColor),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    conversation!.users,
                    style: TextStyle(fontSize: metaSize, color: metaColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  CupertinoIcons.clock,
                  size: isMac ? 11.5 : 12.5,
                  color: metaColor,
                ),
                const SizedBox(width: 4),
                Text(
                  code_utils.formatPostDate(conversation!.lastModify! * 1000),
                  style: TextStyle(fontSize: metaSize, color: metaColor),
                ),
              ],
            ),
          ],
        ),
      );

      if (isMac) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: selected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(onTap: handleTap, child: rowBody),
              ),
            ),
            if (!selected)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 18,
                endIndent: 18,
                color: colorScheme.outlineVariant,
              ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: selected ? selectedBg : Colors.transparent,
            child: InkWell(onTap: handleTap, child: rowBody),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 16,
            color: colorScheme.outlineVariant,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: selected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: InkWell(
            onTap: handleTap,
            child: DecoratedBox(
              decoration: selected
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: colorScheme.primary, width: 3),
                      ),
                    )
                  : const BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(selected ? 13 : 16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text.rich(
                      TextSpan(
                        text: conversation!.subject,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: conversation!.isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: " (${conversation!.posts})",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 元信息行
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        if (conversation!.isMultiUser) ...[
                          Text(
                            '[多人]',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            conversation!.users,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          code_utils.formatPostDate(
                            conversation!.lastModify! * 1000,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }
}
