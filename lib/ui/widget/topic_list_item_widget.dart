import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_action_menu.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;
import 'package:flutter_nga/utils/nga_links.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicListItemWidget extends ConsumerWidget {
  const TopicListItemWidget({
    super.key,
    required this.topic,
    this.blockMode,
    this.onTap,
    this.selected = false,
    this.onLongPress,
    this.trailing,
  });

  final Topic topic;

  /// 主题被屏蔽时的展示模式，由页面通过 [BlockFilter] 判定；null 表示正常展示
  final BlockMode? blockMode;

  /// 自定义点击回调（如大屏双栏时在右侧打开详情）；为空则跳转到独立详情页
  final VoidCallback? onTap;

  /// 是否在大屏双栏列表中处于当前选中状态
  final bool selected;

  final GestureLongPressCallback? onLongPress;

  /// 行尾操作区（如「更多」菜单按钮），显示在标题右侧
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final topicSubject = code_utils.unescapeHtml(topic.subject);
    // select 只在本帖已读状态变化时重建，集合查找为 O(1)
    final isRead = ref.watch(
      readTopicIdsProvider.select((ids) => ids.contains(topic.tid)),
    );

    // 折叠模式
    if (blockMode == BlockMode.COLLAPSE) {
      return _buildCollapsedCard(context, colorScheme);
    }

    // 隐藏模式：页面通常已通过 BlockFilter.visibleTopics 移除，这里兜底
    if (blockMode == BlockMode.GONE) {
      return const SizedBox.shrink();
    }

    // 计算透明度
    final alpha = blockMode == BlockMode.ALPHA ? 0.38 : 1.0;

    if (context.isAppleStyle) {
      return _buildAppleItem(
        context,
        ref,
        topicSubject: topicSubject,
        interfaceState: interfaceState,
        colorScheme: colorScheme,
        textTheme: textTheme,
        isRead: isRead,
        alpha: alpha,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: selected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context, topic, ref),
            onLongPress: onLongPress,
            child: DecoratedBox(
              decoration: selected
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: colorScheme.primary, width: 3),
                      ),
                    )
                  : const BoxDecoration(),
              child: Opacity(
                opacity: alpha,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    selected ? 13 : 16,
                    16,
                    trailing == null ? 16 : 4,
                    16,
                  ),
                  child: _withTrailing(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        _buildTitle(
                          context,
                          topic,
                          topicSubject,
                          interfaceState,
                          textTheme,
                          colorScheme,
                          isRead: isRead,
                        ),

                        const SizedBox(height: 8),

                        // 元信息行
                        _buildMetaRow(context, colorScheme, textTheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _withTrailing(Widget content) {
    final trailing = this.trailing;
    if (trailing == null) return content;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
        trailing,
      ],
    );
  }

  Widget _buildCollapsedCard(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          child: Text(
            "折叠的屏蔽内容",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildAppleItem(
    BuildContext context,
    WidgetRef ref, {
    required String topicSubject,
    required InterfaceSettingsState interfaceState,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isRead,
    required double alpha,
  }) {
    final isMac = context.isMacDesktopAppleStyle;
    final selectedBg = isMac
        ? colorScheme.primary.withValues(alpha: 0.14)
        : colorScheme.primary.withValues(alpha: 0.10);

    Future<void> showContextMenu(Offset? position) async {
      final tid = topic.tid;
      if (tid == null) return;
      final action = await showAppActionMenu<String>(
        context: context,
        globalPosition: position,
        title: topicSubject,
        actions: const [
          AppMenuAction(
            value: 'copy_link',
            label: '复制帖子链接',
            icon: CupertinoIcons.link,
          ),
          AppMenuAction(
            value: 'open_browser',
            label: '在浏览器中打开',
            icon: CupertinoIcons.compass,
          ),
        ],
      );
      if (action == null) return;
      final url = topicWebUrl(tid);
      if (action == 'copy_link') {
        await Clipboard.setData(ClipboardData(text: url));
        AppToast.success('已复制帖子链接');
      } else if (action == 'open_browser') {
        final opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!opened) AppToast.error('无法打开浏览器');
      }
    }

    final isPaintBlockMode = blockMode == BlockMode.PAINT;
    final authorName = name_utils.getShowName(topic.author ?? '');
    final dateText = topic.lastPost != null
        ? code_utils.formatPostDate(topic.lastPost! * 1000)
        : '';

    final metaStyle = textTheme.bodySmall?.copyWith(
      fontSize: isMac ? 11.5 : 12,
      color: isPaintBlockMode
          ? Colors.transparent
          : colorScheme.onSurfaceVariant,
      backgroundColor: isPaintBlockMode ? colorScheme.onSurfaceVariant : null,
    );

    final rowBody = Opacity(
      opacity: alpha,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMac ? 10 : 16,
          isMac ? 9 : 12,
          trailing == null ? (isMac ? 10 : 16) : 4,
          isMac ? 9 : 12,
        ),
        child: _withTrailing(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(
                context,
                topic,
                topicSubject,
                interfaceState,
                textTheme,
                colorScheme,
                isRead: isRead,
                appleCompact: isMac,
              ),
              SizedBox(height: isMac ? 5 : 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      authorName,
                      style: metaStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (topic.hasAttachment()) ...[
                    Icon(
                      CupertinoIcons.paperclip,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text('${topic.replies} 回复', style: metaStyle),
                  if (dateText.isNotEmpty) ...[
                    Text(' · ', style: metaStyle),
                    Text(dateText, style: metaStyle),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isMac) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: GestureDetector(
              onSecondaryTapDown: (d) => showContextMenu(d.globalPosition),
              child: Material(
                color: selected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _handleTap(context, topic, ref),
                  onLongPress: onLongPress,
                  child: rowBody,
                ),
              ),
            ),
          ),
          if (!selected)
            Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 18,
              endIndent: 18,
              color: colorScheme.outlineVariant,
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onSecondaryTapDown: (d) => showContextMenu(d.globalPosition),
          child: Material(
            color: selected ? selectedBg : Colors.transparent,
            child: InkWell(
              onTap: () => _handleTap(context, topic, ref),
              onLongPress: onLongPress ?? () => showContextMenu(null),
              child: rowBody,
            ),
          ),
        ),
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 16,
          color: colorScheme.outlineVariant,
        ),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    Topic topic,
    String topicSubject,
    InterfaceSettingsState interfaceState,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    required bool isRead,
    bool appleCompact = false,
  }) {
    final isPaintBlockMode = blockMode == BlockMode.PAINT;
    final subjectColor = topic.getSubjectColor();
    // 已读：有标题色的保留色相、降低不透明度，普通标题改用弱色
    final titleColor = isRead
        ? subjectColor?.withValues(alpha: 0.6) ?? colorScheme.onSurfaceVariant
        : subjectColor ?? textTheme.bodyLarge?.color;
    final isDeleteBlockMode = blockMode == BlockMode.DELETE_LINE;
    final baseFontSize = appleCompact ? 13.5 : Dimen.titleMedium;

    return Text.rich(
      TextSpan(
        text: topicSubject,
        style: textTheme.titleMedium?.copyWith(
          fontSize: baseFontSize * interfaceState.titleSizeMultiple,
          backgroundColor: isPaintBlockMode
              ? textTheme.bodyMedium?.color
              : null,
          color: isPaintBlockMode ? Colors.transparent : titleColor,
          fontWeight: topic.isBold()
              ? FontWeight.w600
              : (appleCompact ? FontWeight.w500 : FontWeight.normal),
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: isDeleteBlockMode
              ? TextDecoration.lineThrough
              : topic.isUnderline()
              ? TextDecoration.underline
              : null,
          height: interfaceState.lineHeight.size,
        ),
        children: [
          if (topic.parent?.name?.isNotEmpty == true)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    code_utils.unescapeHtml(topic.parent!.name!),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontSize: 10,
                      height: 1,
                    ),
                    // WidgetSpan 已随外层 Text.rich 整体缩放，这里不再重复缩放。
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ),
            ),
          if (topic.locked())
            TextSpan(
              text: " [锁定]",
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (topic.isAssemble())
            TextSpan(
              text: " [合集]",
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isPaintBlockMode = blockMode == BlockMode.PAINT;

    return Row(
      children: [
        // 作者
        Icon(
          Icons.person_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            name_utils.getShowName(topic.author ?? ''),
            style: textTheme.bodySmall?.copyWith(
              color: isPaintBlockMode
                  ? Colors.transparent
                  : colorScheme.onSurfaceVariant,
              backgroundColor: isPaintBlockMode
                  ? colorScheme.onSurfaceVariant
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 附件图标
        if (topic.hasAttachment()) ...[
          Icon(
            Icons.attach_file,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
        ],

        // 回复数
        Icon(
          Icons.chat_bubble_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          "${topic.replies}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 12),

        // 时间
        Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          code_utils.formatPostDate(topic.lastPost! * 1000),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, Topic topic, WidgetRef ref) {
    ref
        .read(topicHistoryProvider.notifier)
        .insertHistory(topic.createHistory());
    if (onTap != null) {
      onTap!();
      return;
    }
    Routes.navigateToWithParams(context, Routes.TOPIC_DETAIL, {
      'tid': '${topic.tid}',
      'fid': '${topic.fid}',
      if (topic.subject != null) 'subject': topic.subject!,
    });
  }
}
