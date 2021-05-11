import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_comment_item_widget.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/dash.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicReplyItemWidget extends StatefulWidget {
  final Reply reply;
  final User? user;
  final Group? group;
  final List<Medal>? medalList;
  final List<User>? userList;
  final bool hot;

  const TopicReplyItemWidget({
    Key? key,
    required this.reply,
    this.user,
    this.group,
    this.medalList,
    this.userList,
    this.hot = false,
  }) : super(key: key);

  @override
  _TopicReplyItemState createState() => _TopicReplyItemState();
}

class _TopicReplyItemState extends State<TopicReplyItemWidget> {
  bool _attachmentsExpanded = false;

  final _actions = const ["引用", "回复", "只看他"];

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
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          child: Icon(Icons.more_vert),
                          onSelected: _onMenuSelected,
                          itemBuilder: (BuildContext context) {
                            return _actions.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text(
                            "级别: ${widget.group == null ? "" : widget.group!.name}",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2?.color,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
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
                          padding: EdgeInsets.only(right: 16),
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
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                widget.hot ? "[热评]" : "[${widget.reply.lou} 楼]",
                style: TextStyle(
                  color: widget.hot
                      ? Colors.redAccent
                      : Theme.of(context).textTheme.bodyText2?.color,
                  fontSize: Dimen.caption,
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
              codeUtils.unescapeHtml(widget.reply.subject),
              style: TextStyle(
                fontSize: Dimen.title,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
          ),
        ),
        SizedBox(
          height: codeUtils.isStringEmpty(widget.reply.content) ? 0 : null,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: NgaHtmlContentWidget(content: widget.reply.content),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: widget.reply.commentList!.isEmpty ? 0 : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: _getCommentListWidgets(),
            ),
          ),
        ),
        Offstage(
          offstage: widget.reply.attachmentList!.isEmpty,
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
                  color: Palette.getColorThumbBackground(context),
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
                        onTap: _toggleLike,
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
                          onTap: _toggleDislike,
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
                widget.reply.postDate!,
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

  _toggleLike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .likeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
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

  _toggleDislike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .dislikeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
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

  _onMenuSelected(String action) {
    if (action == _actions[0]) {
      // 引用
      String quoteContent =
          "[quote][pid=${widget.reply.pid},${widget.reply.tid},1]Reply[/pid] [b]Post by [uid=${widget.user!.uid}]${widget.user!.getShowName()}[/uid] (${widget.reply.postDate}):[/b]\n\n${widget.reply.quoteContent}[/quote]";
      Routes.navigateTo(
        context,
        "${Routes.TOPIC_PUBLISH}?tid=${widget.reply.tid}&fid=${widget.reply.fid}",
        routeSettings: RouteSettings(arguments: quoteContent),
      );
    } else if (action == _actions[1]) {
      // 回复
      String replyContent =
          "[b]Reply to [pid=${widget.reply.pid},${widget.reply.tid},1]Reply[/pid] Post by [uid=${widget.user!.uid}]${widget.user!.getShowName()}[/uid] (${widget.reply.postDate})[/b]";
      Routes.navigateTo(
        context,
        "${Routes.TOPIC_PUBLISH}?tid=${widget.reply.tid}&fid=${widget.reply.fid}",
        routeSettings: RouteSettings(arguments: replyContent),
      );
    } else if (action == _actions[2]) {
      Routes.navigateTo(context,
          "${Routes.TOPIC_DETAIL}?tid=${widget.reply.tid}&fid=${widget.reply.fid}}&authorid=${widget.reply.authorId}");
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
    widgets.addAll(widget.reply.commentList!.map((comment) =>
        TopicReplyCommentItemWidget(
            comment,
            widget.userList!
                .firstWhereOrNull((user) => user.uid == comment.authorId))));
    return widgets;
  }

  _getAttachments() {
    List<Widget> columnWidgets = [];
    final button = ElevatedButton(
      style: ButtonStyle(elevation: MaterialStateProperty.all(0)),
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
      attachmentWidgets.addAll(widget.reply.attachmentList!.map((attachment) {
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
