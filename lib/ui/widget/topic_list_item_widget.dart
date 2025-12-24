import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/store/settings/blocklist_settings_store.dart';
import 'package:flutter_nga/store/settings/interface_settings_store.dart';
import 'package:flutter_nga/store/topic/topic_history_store.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/name_utils.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class TopicListItemWidget extends StatelessWidget {
  const TopicListItemWidget({
    Key? key,
    required this.topic,
    this.needBlock = true,
    this.onLongPress,
  }) : super(key: key);

  final Topic topic;
  final bool needBlock;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final blockStore = Provider.of<BlocklistSettingsStore>(context);
    final blockEnabled =
        blockStore.clientBlockEnabled && blockStore.listBlockEnabled;
    final blockMode = blockStore.blockMode;
    final topicSubject = codeUtils.unescapeHtml(topic.subject);
    final isTopicBlocked = blockStore.blockUserList.contains(topic.author) ||
        blockStore.blockUserList.contains(topic.authorId) ||
        blockStore.blockWordList
            .any((blockWord) => topicSubject.contains(blockWord));
    final columnChildren = <Widget>[];
    if (blockEnabled && isTopicBlocked && blockMode == BlockMode.COLLAPSE) {
      columnChildren.add(Padding(
        padding: EdgeInsets.all(16),
        child: Text("折叠的屏蔽内容"),
      ));
    } else {
      var alpha = 1.0;
      if (blockEnabled && isTopicBlocked) {
        if (blockMode == BlockMode.ALPHA) {
          alpha = 0.38;
        } else if (blockMode == BlockMode.GONE) {
          alpha = 0.0;
        }
      }
      columnChildren.add(Opacity(
        opacity: alpha,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                child: _getTitleText(context, topic, topicSubject, blockEnabled,
                    blockMode, isTopicBlocked),
                width: double.infinity,
              ),
              SizedBox(
                child: (topic.parent != null &&
                        topic.parent!.name != null &&
                        topic.parent!.name!.isNotEmpty)
                    ? Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "[${codeUtils.unescapeHtml(topic.parent!.name)}]",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : null,
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Padding(
                      child: Icon(
                        CommunityMaterialIcons.account,
                        size: Dimen.icon,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      padding: EdgeInsets.only(right: 8),
                    ),
                    Expanded(
                      child: Text(
                        getShowName(topic.author!),
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: blockEnabled &&
                                  isTopicBlocked &&
                                  blockMode == BlockMode.PAINT
                              ? Colors.transparent
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          backgroundColor: blockEnabled &&
                                  isTopicBlocked &&
                                  blockMode == BlockMode.PAINT
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: (topic.hasAttachment()
                          ? Icon(
                              Icons.attachment,
                              size: Dimen.icon,
                              color: Theme.of(context).iconTheme.color,
                            )
                          : null),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        CommunityMaterialIcons.comment,
                        size: Dimen.icon,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Text(
                      "${topic.replies}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(
                        CommunityMaterialIcons.clock,
                        size: Dimen.icon,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Text(
                      "${codeUtils.formatPostDate(topic.lastPost! * 1000)}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    }
    columnChildren.add(Divider(height: 1));
    return InkWell(
      onTap: () => _goTopicDetail(context, topic),
      onLongPress: onLongPress,
      child: Column(children: columnChildren),
    );
  }

  _getTitleText(
    BuildContext context,
    Topic topic,
    String topicSubject,
    bool blockEnabled,
    BlockMode blockMode,
    bool isTopicBlocked,
  ) {
    final isPaintBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.PAINT;
    final isDeleteBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.DELETE_LINE;
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: codeUtils.unescapeHtml(topic.subject),
        style: TextStyle(
          fontSize: Dimen.subheading *
              Provider.of<InterfaceSettingsStore>(context).titleSizeMultiple,
          backgroundColor: isPaintBlockMode
              ? Theme.of(context).textTheme.bodyMedium?.color
              : null,
          color: isPaintBlockMode
              ? Colors.transparent
              : topic.getSubjectColor() ??
                  Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: topic.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: isDeleteBlockMode
              ? TextDecoration.lineThrough
              : topic.isUnderline()
                  ? TextDecoration.underline
                  : null,
          height: Provider.of<InterfaceSettingsStore>(context).lineHeight.size,
        ),
        children: <TextSpan>[
          TextSpan(
            text: (topic.locked() ? " [锁定]" : ""),
            style: TextStyle(
              color: Palette.colorTextLock,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              decoration: null,
            ),
          ),
          TextSpan(
            text: (topic.isAssemble() ? " [合集]" : ""),
            style: TextStyle(
              color: Palette.colorTextAssemble,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              decoration: null,
            ),
          ),
        ],
      ),
    );
  }

  _goTopicDetail(BuildContext context, Topic topic) {
    final store = TopicHistoryStore();
    store.insertHistory(topic.createHistory());
    Routes.navigateTo(
      context,
      "${Routes.TOPIC_DETAIL}?tid=${topic.tid}&fid=${topic.fid}&subject=${topic.subject!}",
    );
  }
}
