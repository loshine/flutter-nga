import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/store/topic_history_store.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicHistoryListItemWidget extends StatelessWidget {
  const TopicHistoryListItemWidget(
      {Key key, this.topicHistory, this.onLongPress})
      : super(key: key);

  final TopicHistory topicHistory;
  final GestureLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _goTopicDetail(context, topicHistory),
      onLongPress: onLongPress,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  child: _getTitleText(topicHistory),
                  width: double.infinity,
                ),
                SizedBox(
                  child: (topicHistory.topicParentName != null &&
                          topicHistory.topicParentName.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "[$topicHistory]",
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
                          topicHistory.author,
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Palette.colorTextSecondary,
                          ),
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

  _getTitleText(TopicHistory topicHistory) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: codeUtils.unescapeHtml(topicHistory.subject),
        style: TextStyle(
          fontSize: Dimen.subheading,
          color: topicHistory.getSubjectColor(),
          fontWeight:
              topicHistory.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              topicHistory.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration:
              topicHistory.isUnderline() ? TextDecoration.underline : null,
        ),
        children: <TextSpan>[
          TextSpan(
            text: (topicHistory.locked() ? " [锁定]" : ""),
            style: TextStyle(
              color: Palette.colorTextLock,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              decoration: null,
            ),
          ),
          TextSpan(
            text: (topicHistory.isAssemble() ? " [合集]" : ""),
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

  _goTopicDetail(BuildContext context, TopicHistory topicHistory) {
    final store = TopicHistoryStore();
    store.insertHistory(topicHistory.createNewHistory());
    Routes.navigateTo(context,
        "${Routes.TOPIC_DETAIL}?tid=${topicHistory.tid}&fid=${topicHistory.fid}&subject=${codeUtils.fluroCnParamsEncode(topicHistory.subject)}");
  }
}
