import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_comment_item_widget.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/blocked_content.dart';
import 'package:flutter_nga/ui/widget/dash.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;
import 'package:flutter_nga/utils/nga_links.dart';
import 'package:flutter_nga/utils/parser/plain_text.dart';
import 'package:flutter_nga/utils/route.dart';

/// 楼层右上角菜单项
enum ReplyMenuAction {
  quote('引用'),
  reply('回复'),
  onlyAuthor('只看他'),
  copyContent('复制内容'),
  copyLink('复制楼层链接'),
  viewUser('查看用户'),
  blockUser('屏蔽该用户');

  const ReplyMenuAction(this.label);

  final String label;
}

class TopicReplyItemWidget extends ConsumerStatefulWidget {
  final Reply reply;
  final User? user;
  final Group? group;
  final List<Medal>? medalList;
  final List<User>? userList;

  /// 同页楼层引用正文缓存，Reply to 补原文
  final Map<int, String>? quoteBodyByPid;

  /// 评论占位楼层对应的真实评论（按 pid 关联），非评论楼层为 null
  final Reply? commentSource;

  /// 楼层被屏蔽时的展示模式，由页面通过 [BlockFilter] 判定；null 表示正常展示
  final BlockMode? blockMode;

  /// 与 [Reply.commentList] 一一对应的评论屏蔽模式；null 表示均不屏蔽
  final List<BlockMode?>? commentBlockModes;

  /// 是否为楼主发的楼层，用户名旁显示「楼主」标记
  final bool isTopicAuthor;

  const TopicReplyItemWidget({
    super.key,
    required this.reply,
    this.user,
    this.group,
    this.medalList,
    this.userList,
    this.quoteBodyByPid,
    this.commentSource,
    this.blockMode,
    this.commentBlockModes,
    this.isTopicAuthor = false,
  });

  @override
  ConsumerState<TopicReplyItemWidget> createState() => _TopicReplyItemState();
}

class _TopicReplyItemState extends ConsumerState<TopicReplyItemWidget> {
  bool _attachmentsExpanded = false;

  /// 点赞 / 点踩请求进行中，期间忽略重复点击。
  bool _reacting = false;

  /// 匿名用户没有可访问的主页，也无法按用户名屏蔽。
  bool get _isAnonymous =>
      (widget.user?.username ?? '').startsWith('#anony_') ||
      (widget.user?.uid ?? 0) <= 0;

  List<ReplyMenuAction> get _actions => [
    ReplyMenuAction.quote,
    ReplyMenuAction.reply,
    ReplyMenuAction.onlyAuthor,
    ReplyMenuAction.copyContent,
    ReplyMenuAction.copyLink,
    if (!_isAnonymous) ...[ReplyMenuAction.viewUser, ReplyMenuAction.blockUser],
  ];

  @override
  Widget build(BuildContext context) {
    // 评论楼层使用真实评论内容渲染
    final contentReply = widget.commentSource ?? widget.reply;
    final colorScheme = Theme.of(context).colorScheme;
    final thumbBg = colorScheme.surfaceContainerHigh;
    final thumbFgActive = colorScheme.primary;
    final thumbFgInactive = colorScheme.onSurfaceVariant;
    final isLiked = widget.reply.recommend == 1;
    final isDisliked = widget.reply.recommend == -1;
    final blockDecoration = widget.blockMode == BlockMode.DELETE_LINE
        ? TextDecoration.lineThrough
        : null;
    final visibleComments = _visibleComments();

    final floor = Column(
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
                padding: EdgeInsets.only(top: 4, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: UsernameText(
                                  username: widget.user!.username ?? '',
                                  uid: widget.user!.uid,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    decoration: blockDecoration,
                                  ),
                                ),
                              ),
                              if (widget.isTopicAuthor) ...[
                                const SizedBox(width: 6),
                                _TopicAuthorBadge(),
                              ],
                            ],
                          ),
                        ),
                        // 用 icon 参数让菜单按钮拥有 48dp 触控区。
                        PopupMenuButton<ReplyMenuAction>(
                          tooltip: '楼层操作',
                          icon: const Icon(Icons.more_vert),
                          onSelected: _onMenuSelected,
                          itemBuilder: (BuildContext context) => [
                            for (final action in _actions)
                              PopupMenuItem<ReplyMenuAction>(
                                value: action,
                                child: Text(action.label),
                              ),
                          ],
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
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              fontSize: Dimen.bodySmall,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text(
                            "威望: ${widget.user!.getShowReputation()}",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              fontSize: Dimen.bodySmall,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text(
                            "发帖: ${widget.user!.postNum ?? 0}",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                              fontSize: Dimen.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6, right: 12),
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
              child: Row(
                children: [
                  Text(
                    "[${widget.reply.lou} 楼]",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: Dimen.bodySmall,
                    ),
                  ),
                  // 评论楼层标识
                  if (widget.commentSource != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF909090),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "评论",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimen.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          // 评论楼层隐藏"对主题发表了一条评论"占位标题
          height:
              widget.commentSource != null ||
                  code_utils.isStringEmpty(widget.reply.subject)
              ? 0
              : null,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              code_utils.unescapeHtml(widget.reply.subject),
              style: TextStyle(
                fontSize: Dimen.titleLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                decoration: blockDecoration,
              ),
            ),
          ),
        ),
        SizedBox(
          height: code_utils.isStringEmpty(contentReply.content) ? 0 : null,
          // HtmlWidget 宽度随内容收缩，不撑满会被外层 Column 居中。
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            // 长按选择、复制正文；链接、图片、折叠块等点击手势照常生效。
            child: SelectionArea(
              child: NgaHtmlContentWidget(
                content: contentReply.content,
                authorId: contentReply.authorId,
                tid: contentReply.tid,
                pid: contentReply.pid,
                postDateTimestamp: contentReply.postDateTimestamp,
                quoteBodyByPid: widget.quoteBodyByPid,
                textDecoration: blockDecoration,
              ),
            ),
          ),
        ),
        if (visibleComments.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(children: _getCommentListWidgets(visibleComments)),
            ),
          ),
        Offstage(
          offstage: widget.reply.attachmentList.isEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Opacity(
                  opacity: 0.5,
                  child: Dash(
                    dashColor: Theme.of(context).dividerColor,
                    length: MediaQuery.sizeOf(context).width,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '附件',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
          padding: EdgeInsets.fromLTRB(8, 4, 16, 4),
          child: Row(
            children: [
              // 按钮保留 48dp 触控区，底色胶囊只画在图标与分数周围，外观保持紧凑。
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    left: 8,
                    right: 8,
                    top: 13,
                    bottom: 13,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: thumbBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _reactionButton(
                        tooltip: "点赞",
                        icon: isLiked
                            ? CommunityMaterialIcons.thumb_up
                            : CommunityMaterialIcons.thumb_up_outline,
                        color: isLiked ? thumbFgActive : thumbFgInactive,
                        onPressed: _toggleLike,
                      ),
                      Text(
                        "${contentReply.score}",
                        style: TextStyle(
                          fontSize: Dimen.bodySmall,
                          color: isLiked || isDisliked
                              ? thumbFgActive
                              : thumbFgInactive,
                        ),
                      ),
                      _reactionButton(
                        tooltip: "点踩",
                        icon: isDisliked
                            ? CommunityMaterialIcons.thumb_down
                            : CommunityMaterialIcons.thumb_down_outline,
                        color: isDisliked ? thumbFgActive : thumbFgInactive,
                        onPressed: _toggleDislike,
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Text(
                widget.reply.postDate!,
                style: TextStyle(
                  fontSize: Dimen.bodySmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );

    return BlockedContent(mode: widget.blockMode, child: floor);
  }

  /// 隐藏模式的评论直接移除，其余评论连同各自的屏蔽模式一起返回
  List<(Reply, BlockMode?)> _visibleComments() {
    final modes = widget.commentBlockModes;
    return [
      for (final (index, comment) in widget.reply.commentList.indexed)
        if (modes == null || index >= modes.length)
          (comment, null)
        else if (modes[index] != BlockMode.GONE)
          (comment, modes[index]),
    ];
  }

  List<Widget> _getMedalListWidgets() {
    if (widget.medalList!.isEmpty) {
      return [
        Text(
          "-",
          style: TextStyle(
            fontSize: Dimen.bodySmall,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ];
    }
    return widget.medalList!.map((medal) {
      return Padding(
        padding: EdgeInsets.only(right: 4),
        child: CachedNetworkImage(
          imageUrl: "$ngaImage4Origin/ngabbs/medal/${medal.image}",
          width: 12,
          height: 12,
          fit: BoxFit.cover,
        ),
      );
    }).toList();
  }

  Widget _reactionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      color: color,
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.padded),
    );
  }

  Future<void> _toggleLike() async {
    if (_reacting) return;
    _reacting = true;
    try {
      final reaction = await Data().topicRepository.likeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
      if (!mounted) return;
      setState(() {
        widget.reply.score += reaction.countChange;
        if (reaction.countChange > 0) {
          widget.reply.recommend = 1;
        } else if (reaction.countChange < 0) {
          widget.reply.recommend = 0;
        }
      });
      AppToast.success(reaction.message);
    } catch (err) {
      debugPrint(err.toString());
      AppToast.error(err);
    } finally {
      _reacting = false;
    }
  }

  Future<void> _toggleDislike() async {
    if (_reacting) return;
    _reacting = true;
    try {
      final reaction = await Data().topicRepository.dislikeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
      if (!mounted) return;
      setState(() {
        widget.reply.score += reaction.countChange;
        if (reaction.countChange < 0) {
          widget.reply.recommend = -1;
        } else if (reaction.countChange > 0) {
          widget.reply.recommend = 0;
        }
      });
      AppToast.success(reaction.message);
    } catch (err) {
      debugPrint(err.toString());
      AppToast.error(err);
    } finally {
      _reacting = false;
    }
  }

  void _onMenuSelected(ReplyMenuAction action) {
    final displayName = name_utils.getShowName(widget.user!.username ?? '');
    switch (action) {
      case ReplyMenuAction.quote:
        String quoteContent =
            "[quote][pid=${widget.reply.pid},${widget.reply.tid},1]Reply[/pid] [b]Post by [uid=${widget.user!.uid}]$displayName[/uid] (${widget.reply.postDate}):[/b]\n\n${widget.reply.quoteContent}[/quote]";
        Routes.navigateTo(
          context,
          "${Routes.TOPIC_PUBLISH}?tid=${widget.reply.tid}&fid=${widget.reply.fid}",
          extra: quoteContent,
        );
      case ReplyMenuAction.reply:
        String replyContent =
            "[b]Reply to [pid=${widget.reply.pid},${widget.reply.tid},1]Reply[/pid] Post by [uid=${widget.user!.uid}]$displayName[/uid] (${widget.reply.postDate})[/b]";
        Routes.navigateTo(
          context,
          "${Routes.TOPIC_PUBLISH}?tid=${widget.reply.tid}&fid=${widget.reply.fid}",
          extra: replyContent,
        );
      case ReplyMenuAction.onlyAuthor:
        Routes.navigateTo(
          context,
          "${Routes.TOPIC_DETAIL}?tid=${widget.reply.tid}&fid=${widget.reply.fid}&authorid=${widget.reply.authorId}",
        );
      case ReplyMenuAction.copyContent:
        _copyContent();
      case ReplyMenuAction.copyLink:
        _copyToClipboard(
          replyWebUrl(tid: widget.reply.tid, pid: widget.reply.pid),
          '已复制楼层链接',
        );
      case ReplyMenuAction.viewUser:
        Routes.navigateTo(
          context,
          Routes.USER,
          queryParams: {'uid': '${widget.user!.uid}'},
        );
      case ReplyMenuAction.blockUser:
        _confirmBlockUser(displayName);
    }
  }

  void _copyContent() {
    final contentReply = widget.commentSource ?? widget.reply;
    final text = ngaContentToPlainText(
      contentReply.content,
      authorId: contentReply.authorId,
      tid: contentReply.tid,
      pid: contentReply.pid,
      postDateTimestamp: contentReply.postDateTimestamp,
    );
    if (text.isEmpty) {
      AppToast.info('该楼层没有可复制的文字');
      return;
    }
    _copyToClipboard(text, '已复制楼层内容');
  }

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    AppToast.success(message);
  }

  void _confirmBlockUser(String displayName) {
    final username = widget.user!.username ?? '';
    if (username.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: '屏蔽用户',
        content: '确定屏蔽「$displayName」吗？屏蔽名单与网页版同步，可在「设置 - 屏蔽设置」中移除。',
        confirmText: '屏蔽',
        destructive: true,
        onConfirm: () => _blockUser(username),
      ),
    );
  }

  Future<void> _blockUser(String username) async {
    final notifier = ref.read(blocklistSettingsProvider.notifier);
    try {
      // 名单整体提交到服务端，先同步一次，避免用本地旧名单覆盖网页端的改动。
      await notifier.load();
      final settings = ref.read(blocklistSettingsProvider);
      if (settings.blockUserList.contains(username)) {
        AppToast.info('该用户已在屏蔽名单中');
        return;
      }
      final message = await notifier.addUser(username);
      final enabled = ref.read(blocklistSettingsProvider).clientBlockEnabled;
      AppToast.success(enabled ? message : '$message（客户端屏蔽未开启，开启后生效）');
    } catch (err) {
      AppToast.error(err);
    }
  }

  List<Container> _getCommentListWidgets(List<(Reply, BlockMode?)> comments) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "评论 ${comments.length}",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            for (final (index, (comment, mode)) in comments.indexed) ...[
              if (index > 0)
                const Divider(height: 1, indent: 12, endIndent: 12),
              BlockedContent(
                mode: mode,
                child: TopicReplyCommentItemWidget(
                  comment,
                  widget.userList!.firstWhereOrNull(
                    (user) => user.uid == comment.authorId,
                  ),
                  textDecoration: mode == BlockMode.DELETE_LINE
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    ];
  }

  Column _getAttachments() {
    List<Widget> columnWidgets = [];
    final button = FilledButton.tonal(
      onPressed: () =>
          setState(() => _attachmentsExpanded = !_attachmentsExpanded),
      style: FilledButton.styleFrom(
        minimumSize: Size(0, 32),
        padding: EdgeInsets.all(16),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        _attachmentsExpanded ? "收起附件" : "展开附件",
        style: TextStyle(fontSize: Dimen.labelLarge),
      ),
    );
    columnWidgets.add(button);
    if (_attachmentsExpanded) {
      List<Widget> attachmentWidgets = [];
      attachmentWidgets.addAll(
        widget.reply.attachmentList.map((attachment) {
          return Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: attachment.realUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'images/default_forum_icon.png',
                      width: 48,
                      height: 48,
                    ),
                    errorWidget: (context, url, err) => Image.asset(
                      'images/default_forum_icon.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  // 水波纹盖在图片上方，点击查看大图。
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () =>
                          Routes.openPhotoPreview(context, attachment.realUrl),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
      columnWidgets.add(Wrap(children: attachmentWidgets));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnWidgets,
    );
  }
}

/// 楼主标记：主题色描边小标签
class _TopicAuthorBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '楼主',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: Dimen.labelSmall,
          height: 1.4,
        ),
      ),
    );
  }
}
