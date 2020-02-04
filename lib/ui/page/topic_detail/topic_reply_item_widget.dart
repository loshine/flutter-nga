import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_comment_item_widget.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/renderer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicReplyItemWidget extends StatefulWidget {
  final Reply reply;
  final User user;
  final Group group;
  final List<Medal> medalList;
  final List<User> userList;

  const TopicReplyItemWidget({
    Key key,
    this.reply,
    this.user,
    this.group,
    this.medalList,
    this.userList,
  }) : super(key: key);

  @override
  _TopicReplyItemState createState() => _TopicReplyItemState();
}

class _TopicReplyItemState extends State<TopicReplyItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: AvatarWidget(
                widget.user.avatar,
                username: widget.user.username,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.user.getShowName(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Text(
                          "[${widget.reply.lou} 楼]",
                          style: TextStyle(
                            color: Palette.colorTextSecondary,
                            fontSize: Dimen.caption,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "级别: ${widget.group == null ? "" : widget.group.name}",
                          style: TextStyle(
                            color: Palette.colorTextSecondary,
                            fontSize: Dimen.caption,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Text(
                            "威望: ${widget.user.getShowReputation()}",
                            style: TextStyle(
                              color: Palette.colorTextSecondary,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Text(
                            "发帖: ${widget.user.postNum ?? 0}",
                            style: TextStyle(
                              color: Palette.colorTextSecondary,
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
          height: codeUtils.isStringEmpty(widget.reply.subject) ? 0 : null,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              codeUtils.unescapeHtml(widget.reply.subject) ?? "",
              style: TextStyle(
                fontSize: Dimen.title,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          height: codeUtils.isStringEmpty(widget.reply.content) ? 0 : null,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Html(
              useRichText: false,
              data: NgaContentParser.parse(widget.reply.content),
              customRender: ngaRenderer,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: widget.reply.commentList.isEmpty ? 0 : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: _getCommentListWidgets(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Palette.colorThumbBackground,
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
                          "${widget.reply.score}",
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
                widget.reply.postDate,
                style: TextStyle(
                  fontSize: Dimen.caption,
                  color: Palette.colorTextSecondary,
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
    if (widget.medalList.isEmpty)
      return [
        Text(
          "-",
          style: TextStyle(
            fontSize: Dimen.caption,
            color: Palette.colorTextSecondary,
          ),
        )
      ];
    return widget.medalList.map((medal) {
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
          .likeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
      Fluttertoast.showToast(
        msg: reaction.message,
        gravity: ToastGravity.CENTER,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  toggleDislike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .dislikeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
      Fluttertoast.showToast(
        msg: reaction.message,
        gravity: ToastGravity.CENTER,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
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
            color: Palette.colorDivider,
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
    widgets.addAll(widget.reply.commentList.map((comment) =>
        TopicReplyCommentItemWidget(
            comment,
            widget.userList.firstWhere((user) => user.uid == comment.authorId,
                orElse: () => null))));
    return widgets;
  }
}
