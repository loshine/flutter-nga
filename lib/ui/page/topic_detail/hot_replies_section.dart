import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;

/// 热点回复区块：标题 + 容器包裹的紧凑热评卡片列表
/// 点击卡片跳转原楼层（与网页端"到原楼层"链接对应）
class HotRepliesSection extends StatelessWidget {
  final List<Reply> replies;
  final List<User> userList;

  /// 跳转原楼层回调，参数为楼层号（lou）
  final ValueChanged<int>? onJumpToFloor;

  const HotRepliesSection({
    super.key,
    required this.replies,
    required this.userList,
    this.onJumpToFloor,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.whatshot, size: 18, color: Colors.deepOrange),
              const SizedBox(width: 4),
              Text(
                '热点回复',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, reply) in replies.indexed) ...[
                  if (index > 0)
                    const Divider(height: 1, indent: 12, endIndent: 12),
                  _HotReplyItemCard(
                    reply: reply,
                    user: _findUser(reply.authorId),
                    onJumpToFloor: onJumpToFloor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  User? _findUser(int? authorId) {
    for (final user in userList) {
      if (user.uid == authorId) return user;
    }
    return null;
  }
}

/// 紧凑热评卡片：头像 + 作者 + 楼号 + 赞数 + 限高折叠内容
class _HotReplyItemCard extends StatefulWidget {
  final Reply reply;
  final User? user;
  final ValueChanged<int>? onJumpToFloor;

  const _HotReplyItemCard({
    required this.reply,
    required this.user,
    this.onJumpToFloor,
  });

  @override
  State<_HotReplyItemCard> createState() => _HotReplyItemCardState();
}

class _HotReplyItemCardState extends State<_HotReplyItemCard> {
  /// 内容字符数超过该阈值才提供折叠
  static const _collapseThreshold = 240;

  /// 折叠态内容最大高度
  static const _collapsedHeight = 140.0;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reply = widget.reply;
    final lou = reply.lou ?? 0;

    final contentWidget = NgaHtmlContentWidget(
      content: reply.content,
      authorId: reply.authorId,
      tid: reply.tid,
      pid: reply.pid,
      postDateTimestamp: reply.postDateTimestamp,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: lou > 0 ? () => widget.onJumpToFloor?.call(lou) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWidget(widget.user?.avatar, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name_utils.getShowName(widget.user?.username ?? ''),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (lou > 0)
                    Text(
                      '$lou楼',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    CommunityMaterialIcons.thumb_up,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${reply.score}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              reply.content.length > _collapseThreshold
                  ? _buildCollapsibleContent(contentWidget, colorScheme)
                  : contentWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleContent(Widget content, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: Motion.durationMedium2,
            curve: Motion.emphasized,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: _expanded ? double.infinity : _collapsedHeight,
              ),
              child: content,
            ),
          ),
        ),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _expanded ? '收起' : '展开全部',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
