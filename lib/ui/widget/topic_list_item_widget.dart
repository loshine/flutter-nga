import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicListItemWidget extends ConsumerWidget {
  const TopicListItemWidget({
    super.key,
    required this.topic,
    this.needBlock = true,
    this.onLongPress,
  });

  final Topic topic;
  final bool needBlock;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockState = ref.watch(blocklistSettingsProvider);
    final interfaceState = ref.watch(interfaceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final blockEnabled =
        blockState.clientBlockEnabled && blockState.listBlockEnabled;
    final blockMode = blockState.blockMode;
    final topicSubject = code_utils.unescapeHtml(topic.subject);
    final isTopicBlocked = _isBlocked(blockState, topicSubject);

    // 折叠模式
    if (blockEnabled && isTopicBlocked && blockMode == BlockMode.COLLAPSE) {
      return _buildCollapsedCard(context, colorScheme);
    }

    // 隐藏模式
    if (blockEnabled && isTopicBlocked && blockMode == BlockMode.GONE) {
      return const SizedBox.shrink();
    }

    // 计算透明度
    final alpha =
        (blockEnabled && isTopicBlocked && blockMode == BlockMode.ALPHA)
            ? 0.38
            : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _goTopicDetail(context, topic, ref),
          onLongPress: onLongPress,
          child: Opacity(
            opacity: alpha,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  _buildTitle(
                    context,
                    topic,
                    topicSubject,
                    blockEnabled,
                    blockMode,
                    isTopicBlocked,
                    interfaceState,
                    textTheme,
                    colorScheme,
                  ),

                  const SizedBox(height: 8),

                  // 元信息行
                  _buildMetaRow(
                    context,
                    blockEnabled,
                    blockMode,
                    isTopicBlocked,
                    colorScheme,
                    textTheme,
                  ),
                ],
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

  bool _isBlocked(BlocklistSettingsState blockState, String topicSubject) {
    return blockState.blockUserList.contains(topic.author) ||
        blockState.blockUserList.contains(topic.authorId) ||
        blockState.blockWordList
            .any((blockWord) => topicSubject.contains(blockWord));
  }

  Widget _buildCollapsedCard(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          child: Text(
            "折叠的屏蔽内容",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
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

  Widget _buildTitle(
    BuildContext context,
    Topic topic,
    String topicSubject,
    bool blockEnabled,
    BlockMode blockMode,
    bool isTopicBlocked,
    InterfaceSettingsState interfaceState,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final isPaintBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.PAINT;
    final isDeleteBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.DELETE_LINE;

    return RichText(
      text: TextSpan(
        text: topicSubject,
        style: textTheme.titleMedium?.copyWith(
          fontSize: Dimen.titleMedium * interfaceState.titleSizeMultiple,
          backgroundColor:
              isPaintBlockMode ? textTheme.bodyMedium?.color : null,
          color: isPaintBlockMode
              ? Colors.transparent
              : topic.getSubjectColor() ?? textTheme.bodyLarge?.color,
          fontWeight: topic.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: isDeleteBlockMode
              ? TextDecoration.lineThrough
              : topic.isUnderline()
                  ? TextDecoration.underline
                  : null,
          height: interfaceState.lineHeight.size,
        ),
        children: [
          if (topic.parent?.name?.isNotEmpty == true)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    code_utils.unescapeHtml(topic.parent!.name!),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          if (topic.locked())
            TextSpan(
              text: " [锁定]",
              style: textTheme.labelMedium?.copyWith(
                color: Colors.red.shade300,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (topic.isAssemble())
            TextSpan(
              text: " [合集]",
              style: textTheme.labelMedium?.copyWith(
                color: Colors.blue.shade300,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    bool blockEnabled,
    BlockMode blockMode,
    bool isTopicBlocked,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isPaintBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.PAINT;

    return Row(
      children: [
        // 作者
        Icon(
          Icons.person_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            topic.author ?? '',
            style: textTheme.bodySmall?.copyWith(
              color: isPaintBlockMode
                  ? Colors.transparent
                  : colorScheme.onSurfaceVariant,
              backgroundColor:
                  isPaintBlockMode ? colorScheme.onSurfaceVariant : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 附件图标
        if (topic.hasAttachment()) ...[
          Icon(
            Icons.attach_file,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
        ],

        // 回复数
        Icon(
          Icons.chat_bubble_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          "${topic.replies}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 12),

        // 时间
        Icon(
          Icons.access_time,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          code_utils.formatPostDate(topic.lastPost! * 1000),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _goTopicDetail(BuildContext context, Topic topic, WidgetRef ref) {
    ref
        .read(topicHistoryProvider.notifier)
        .insertHistory(topic.createHistory());
    Routes.navigateTo(
      context,
      "${Routes.TOPIC_DETAIL}?tid=${topic.tid}&fid=${topic.fid}&subject=${topic.subject!}",
    );
  }
}
