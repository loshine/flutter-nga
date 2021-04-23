import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/store/topic/topic_history_store.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/name_utils.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicListItemWidget extends StatelessWidget {
  const TopicListItemWidget({Key? key, this.topic, this.onLongPress})
      : super(key: key);

  final Topic? topic;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _goTopicDetail(context, topic!),
      onLongPress: onLongPress,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  child: _getTitleText(context, topic!),
                  width: double.infinity,
                ),
                SizedBox(
                  child: (topic!.parent != null &&
                          topic!.parent!.name != null &&
                          topic!.parent!.name!.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "[${codeUtils.unescapeHtml(topic!.parent!.name)}]",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: Dimen.caption,
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
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
                          getShowName(topic!.author!),
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Theme.of(context).textTheme.bodyText2?.color,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: (topic!.hasAttachment()
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
                        "${topic!.replies}",
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: Theme.of(context).textTheme.bodyText2?.color,
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
                        "${codeUtils.formatPostDate(topic!.lastPost! * 1000)}",
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: Theme.of(context).textTheme.bodyText2?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  _getTitleText(BuildContext context, Topic topic) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: codeUtils.unescapeHtml(topic.subject),
        style: TextStyle(
          fontSize: Dimen.subheading,
          color: topic.getSubjectColor() ??
              Theme.of(context).textTheme.bodyText1?.color,
          fontWeight: topic.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: topic.isUnderline() ? TextDecoration.underline : null,
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
    Routes.navigateTo(context,
        "${Routes.TOPIC_DETAIL}?tid=${topic.tid}&fid=${topic.fid}&subject=${codeUtils.fluroCnParamsEncode(topic.subject!)}");
  }
}
