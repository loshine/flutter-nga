import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: selected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: InkWell(
            onTap:
                onTap ??
                () async {
                  final left = await Routes.navigateTo(
                    context,
                    "${Routes.CONVERSATION_DETAIL}?mid=${conversation!.mid}",
                  );
                  if (left == true) onLeft?.call();
                },
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
