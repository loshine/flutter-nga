import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicHistoryListItemWidget extends ConsumerWidget {
  const TopicHistoryListItemWidget({
    Key? key,
    this.topicHistory,
    this.onLongPress,
  }) : super(key: key);

  final TopicHistory? topicHistory;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _goTopicDetail(context, topicHistory!, ref),
      onLongPress: onLongPress,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context, topicHistory!, interfaceState, textTheme),
                
                if (topicHistory?.topicParentName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(Dimen.radiusFull),
                      ),
                      child: Text(
                        codeUtils.unescapeHtml(topicHistory!.topicParentName!),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        topicHistory!.author ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    TopicHistory topicHistory,
    InterfaceSettingsState interfaceState,
    TextTheme textTheme,
  ) {
    return RichText(
      text: TextSpan(
        text: codeUtils.unescapeHtml(topicHistory.subject),
        style: textTheme.titleMedium?.copyWith(
          fontSize: Dimen.titleMedium * interfaceState.titleSizeMultiple,
          color: topicHistory.getSubjectColor() ?? textTheme.bodyLarge?.color,
          fontWeight: topicHistory.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle: topicHistory.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: topicHistory.isUnderline() ? TextDecoration.underline : null,
          height: interfaceState.lineHeight.size,
        ),
        children: [
          if (topicHistory.locked())
            TextSpan(
              text: " [锁定]",
              style: textTheme.labelMedium?.copyWith(
                color: Colors.red.shade300,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (topicHistory.isAssemble())
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

  void _goTopicDetail(BuildContext context, TopicHistory topicHistory, WidgetRef ref) {
    ref.read(topicHistoryProvider.notifier).insertHistory(topicHistory.createNewHistory());
    Routes.navigateTo(
      context,
      "${Routes.TOPIC_DETAIL}?tid=${topicHistory.tid}&fid=${topicHistory.fid}&subject=${topicHistory.subject}",
    );
  }
}
