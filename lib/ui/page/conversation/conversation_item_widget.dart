import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/route.dart';

class ConversationItemWidget extends StatelessWidget {
  final Conversation? conversation;

  const ConversationItemWidget({Key? key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Routes.navigateTo(
          context, "${Routes.CONVERSATION_DETAIL}?mid=${conversation!.mid}"),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: RichText(
                    text: TextSpan(
                      text: conversation!.subject,
                      style: TextStyle(
                        fontWeight: conversation!.isUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: Dimen.subheading,
                        color: Theme.of(context).textTheme.bodyText1?.color,
                      ),
                      children: [
                        TextSpan(
                            text: " (${conversation!.posts})",
                            style: TextStyle(
                              fontSize: Dimen.subheading,
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                            ))
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        CommunityMaterialIcons.account_multiple,
                        color: Theme.of(context).iconTheme.color,
                        size: Dimen.icon,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        conversation!.users,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText2?.color,
                          fontSize: Dimen.caption,
                        ),
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
                      "${codeUtils.formatPostDate(conversation!.lastModify! * 1000)}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Theme.of(context).textTheme.bodyText2?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
