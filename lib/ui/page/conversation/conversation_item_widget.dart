import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class ConversationItemWidget extends StatelessWidget {
  final Conversation? conversation;

  const ConversationItemWidget({Key? key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusM),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Routes.navigateTo(
            context,
            "${Routes.CONVERSATION_DETAIL}?mid=${conversation!.mid}",
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RichText(
                    text: TextSpan(
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
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
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
                      codeUtils.formatPostDate(
                          conversation!.lastModify! * 1000),
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
    );
  }
}