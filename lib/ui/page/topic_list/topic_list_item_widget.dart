import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class TopicListItemWidget extends StatelessWidget {
  const TopicListItemWidget({Key key, this.topic}) : super(key: key);

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _goTopicDetail(context, topic),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  child: _getTitleText(topic),
                  width: double.infinity,
                ),
                SizedBox(
                  child: (topic.parent != null &&
                          topic.parent.name != null &&
                          topic.parent.name.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "[${topic.parent.name}]",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: Dimen.caption,
                              color: Palette.colorTextSecondary,
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
                          size: 12,
                          color: Palette.colorIcon,
                        ),
                        padding: EdgeInsets.only(right: 8),
                      ),
                      Expanded(
                        child: Text(
                          topic.author,
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Palette.colorTextSecondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: (topic.hasAttachment()
                            ? Icon(
                                Icons.attachment,
                                size: 12,
                                color: Palette.colorIcon,
                              )
                            : null),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          CommunityMaterialIcons.comment,
                          size: 12,
                          color: Palette.colorIcon,
                        ),
                      ),
                      Text(
                        "${topic.replies}",
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: Palette.colorTextSecondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
                        child: Icon(
                          CommunityMaterialIcons.clock,
                          size: 12,
                          color: Palette.colorIcon,
                        ),
                      ),
                      Text(
                        "${timeAgo.format(DateTime.fromMillisecondsSinceEpoch(topic.lastPost * 1000))}",
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: Palette.colorTextSecondary,
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

  _getTitleText(Topic topic) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: codeUtils.unescapeHtml(topic.subject),
        style: TextStyle(
          fontSize: Dimen.subheading,
          color: topic.getSubjectColor(),
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TopicDetailPage(topic)));
  }
}
