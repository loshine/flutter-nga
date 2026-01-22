import 'package:community_material_icon/community_material_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_reply_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReplyDetailDialog extends ConsumerStatefulWidget {
  final int? pid;

  const ReplyDetailDialog({Key? key, this.pid}) : super(key: key);

  @override
  ConsumerState<ReplyDetailDialog> createState() => _ReplyDetailState();
}

class _ReplyDetailState extends ConsumerState<ReplyDetailDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topicReplyProvider(widget.pid).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicReplyProvider(widget.pid));
    return AlertDialog(
      backgroundColor: Palette.colorBackground,
      contentPadding: EdgeInsets.zero,
      content: _buildContent(state),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text('关闭'),
        )
      ],
    );
  }

  Widget _buildContent(TopicReplyState state) {
    if (state.replyList.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      );
    } else {
      return _ReplyWidget(
        reply: state.replyList[0],
        user: state.userList[0],
      );
    }
  }
}

class _ReplyWidget extends StatefulWidget {
  final Reply reply;
  final User user;

  const _ReplyWidget({
    Key? key,
    required this.reply,
    required this.user,
  }) : super(key: key);

  @override
  _ReplyWidgetState createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<_ReplyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: AvatarWidget(
                widget.user.avatar,
                size: 24,
                username: widget.user.username,
              ),
            ),
            Expanded(
              child: Text(
                widget.user.getShowName(),
                style: TextStyle(color: Colors.black),
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
                fontSize: Dimen.titleLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
                        onTap: toggleLike,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "${widget.reply.score}",
                          style: TextStyle(
                            fontSize: Dimen.bodySmall,
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
                widget.reply.postDate ?? "",
                style: TextStyle(
                  fontSize: Dimen.bodySmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  toggleLike() async {
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
      if (err is DioException) {
        Fluttertoast.showToast(msg: err.message ?? '');
      } else {
        Fluttertoast.showToast(msg: err.toString());
      }
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
      );
    } catch (err) {
      print(err.toString());
      if (err is DioException) {
        Fluttertoast.showToast(msg: err.message ?? '');
      } else {
        Fluttertoast.showToast(msg: err.toString());
      }
    }
  }
}
