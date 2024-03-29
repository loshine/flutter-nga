import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/store/settings/interface_settings_store.dart';
import 'package:flutter_nga/store/topic/topic_history_store.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/name_utils.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class TopicHistoryListItemWidget extends StatelessWidget {
  const TopicHistoryListItemWidget(
      {Key? key, this.topicHistory, this.onLongPress})
      : super(key: key);

  final TopicHistory? topicHistory;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _goTopicDetail(context, topicHistory!),
      onLongPress: onLongPress,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  child: _getTitleText(context, topicHistory!),
                  width: double.infinity,
                ),
                SizedBox(
                  child: (topicHistory!.topicParentName != null &&
                          topicHistory!.topicParentName!.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "[${codeUtils.unescapeHtml(topicHistory!.topicParentName)}]",
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
                          getShowName(topicHistory!.author!),
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Theme.of(context).textTheme.bodyText2?.color,
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

  _getTitleText(BuildContext context, TopicHistory topicHistory) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: codeUtils.unescapeHtml(topicHistory.subject),
        style: TextStyle(
          fontSize: Dimen.subheading *
              Provider.of<InterfaceSettingsStore>(context).titleSizeMultiple,
          color: topicHistory.getSubjectColor() ??
              Theme.of(context).textTheme.bodyText1?.color,
          fontWeight:
              topicHistory.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              topicHistory.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration:
              topicHistory.isUnderline() ? TextDecoration.underline : null,
          height: Provider.of<InterfaceSettingsStore>(context).lineHeight.size,
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
