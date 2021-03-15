import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_comment_item_widget.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicReplyItemWidget extends StatefulWidget {
  final Reply? reply;
  final User? user;
  final Group? group;
  final List<Medal>? medalList;
  final List<User>? userList;
  final bool hot;
  final bool isDark;

  const TopicReplyItemWidget({
    Key? key,
    this.reply,
    this.user,
    this.group,
    this.medalList,
    this.userList,
    this.hot = false,
    this.isDark = false,
  }) : super(key: key);

  @override
  _TopicReplyItemState createState() => _TopicReplyItemState();
}

class _TopicReplyItemState extends State<TopicReplyItemWidget> {
  bool _attachmentsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: AvatarWidget(
                widget.user!.avatar,
                username: widget.user!.username,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.user!.getShowName(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Text(
                          widget.hot ? "[热评]" : "[${widget.reply!.lou} 楼]",
                          style: TextStyle(
                            color: widget.hot
                                ? Colors.redAccent
                                : Theme.of(context).textTheme.bodyText2?.color,
                            fontSize: Dimen.caption,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "级别: ${widget.group == null ? "" : widget.group!.name}",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText2?.color,
                            fontSize: Dimen.caption,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            "威望: ${widget.user!.getShowReputation()}",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            "发帖: ${widget.user!.postNum ?? 0}",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Wrap(children: _getMedalListWidgets()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: codeUtils.isStringEmpty(widget.reply!.subject) ? 0 : null,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              codeUtils.unescapeHtml(widget.reply!.subject),
              style: TextStyle(
                fontSize: Dimen.title,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          height: codeUtils.isStringEmpty(widget.reply!.content) ? 0 : null,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: NgaHtmlContentWidget(
              content: widget.reply!.content,
              isDark: widget.isDark,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: widget.reply!.commentList!.isEmpty ? 0 : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: _getCommentListWidgets(),
            ),
          ),
        ),
        Offstage(
          offstage: widget.reply!.attachmentList!.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Opacity(
                  opacity: 0.5,
                  child: Dash(
                    dashColor: Theme.of(context).dividerColor,
                    length: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '附件',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: _getAttachments(),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Palette.getColorThumbBackground(widget.isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(
                          CommunityMaterialIcons.thumb_up,
                          color: Colors.white,
                          size: 14,
                        ),
                        onTap: toggleLike,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "${widget.reply!.score}",
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: toggleDislike,
                          child: Icon(
                            CommunityMaterialIcons.thumb_down,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Text(
                widget.reply!.postDate!,
                style: TextStyle(
                  fontSize: Dimen.caption,
                  color: Theme.of(context).textTheme.bodyText2?.color,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  List<Widget> _getMedalListWidgets() {
    if (widget.medalList!.isEmpty)
      return [
        Text(
          "-",
          style: TextStyle(
            fontSize: Dimen.caption,
            color: Theme.of(context).textTheme.bodyText2?.color,
          ),
        )
      ];
    return widget.medalList!.map((medal) {
      return Padding(
        padding: EdgeInsets.only(right: 4),
        child: CachedNetworkImage(
          imageUrl: "https://img4.nga.178.com/ngabbs/medal/${medal.image}",
          width: 12,
          height: 12,
          fit: BoxFit.cover,
        ),
      );
    }).toList();
  }

  toggleLike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .likeReply(widget.reply!.tid, widget.reply!.pid);
      setState(() => widget.reply!.score += reaction.countChange);
      Fluttertoast.showToast(
        msg: reaction.message,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.showToast(
        msg: err.toString(),
      );
    }
  }

  toggleDislike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .dislikeReply(widget.reply!.tid, widget.reply!.pid);
      setState(() => widget.reply!.score += reaction.countChange);
      Fluttertoast.showToast(
        msg: reaction.message,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.showToast(
        msg: err.toString(),
      );
    }
  }

  _getCommentListWidgets() {
    List<Widget> widgets = [];
    widgets.add(Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Text(
        "评论",
        style: TextStyle(
          fontSize: Dimen.subheading,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    widgets.addAll(widget.reply!.commentList!.map((comment) =>
        TopicReplyCommentItemWidget(
            comment,
            widget.userList!
                .firstWhereOrNull((user) => user.uid == comment.authorId))));
    return widgets;
  }

  _getAttachments() {
    List<Widget> columnWidgets = [];
    final button = RaisedButton(
      elevation: 0,
      child: Text(
        _attachmentsExpanded ? "收起附件" : "展开附件",
        style: TextStyle(fontSize: Dimen.button),
      ),
      onPressed: () =>
          setState(() => _attachmentsExpanded = !_attachmentsExpanded),
    );
    columnWidgets.add(button);
    if (_attachmentsExpanded) {
      List<Widget> attachmentWidgets = [];
      attachmentWidgets.addAll(widget.reply!.attachmentList!.map((attachment) {
        return Padding(
          padding: EdgeInsets.only(right: 16),
          child: CachedNetworkImage(
            imageUrl: attachment.realUrl,
            placeholder: (context, url) => Image.asset(
              'images/default_forum_icon.png',
              width: 48,
              height: 48,
            ),
          ),
        );
      }));
      columnWidgets.add(Wrap(children: attachmentWidgets));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnWidgets,
    );
  }
}
