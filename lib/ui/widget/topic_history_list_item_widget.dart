import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_nga/data/entity/topic_history.dart';
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

class TopicHistoryListItemWidget extends ConsumerWidget {
  const TopicHistoryListItemWidget({
    super.key,
    this.topicHistory,
    this.onTap,
    this.selected = false,
    this.onLongPress,
    this.trailing,
  });

  final TopicHistory? topicHistory;

  /// 自定义点击回调（如大屏双栏时在右侧打开详情）；为空则跳转到独立详情页
  final VoidCallback? onTap;

  /// 是否在大屏双栏列表中处于当前选中状态
  final bool selected;

  final GestureLongPressCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (context.isAppleStyle) {
      return _buildAppleItem(
        context,
        ref,
        history: topicHistory!,
        interfaceState: interfaceState,
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        _buildTitle(
          context,
          topicHistory!,
          interfaceState,
          textTheme,
          colorScheme,
        ),
        const SizedBox(height: 8),
        // 元信息行
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name_utils.getShowName(topicHistory!.author ?? ''),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: selected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context, topicHistory!, ref),
            onLongPress: onLongPress,
            child: DecoratedBox(
              decoration: selected
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: colorScheme.primary, width: 3),
                      ),
                    )
                  : const BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  selected ? 13 : 16,
                  16,
                  trailing == null ? 16 : 4,
                  16,
                ),
                child: trailing == null
                    ? content
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: content),
                          trailing!,
                        ],
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

  Widget _buildAppleItem(
    BuildContext context,
    WidgetRef ref, {
    required TopicHistory history,
    required InterfaceSettingsState interfaceState,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isMac = context.isMacDesktopAppleStyle;
    final selectedBg = isMac
        ? colorScheme.primary.withValues(alpha: 0.14)
        : colorScheme.primary.withValues(alpha: 0.10);
    final subjectText = code_utils.unescapeHtml(history.subject);
    final metaStyle = textTheme.bodySmall?.copyWith(
      fontSize: isMac ? 11.5 : 12,
      color: colorScheme.onSurfaceVariant,
    );

    Future<void> showContextMenu(Offset position) async {
      final tid = history.tid;
      final action = await showAppActionMenu<String>(
        context: context,
        globalPosition: position,
        title: subjectText,
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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          context,
          history,
          interfaceState,
          textTheme,
          colorScheme,
          appleCompact: isMac,
        ),
        SizedBox(height: isMac ? 5 : 6),
        Text(
          name_utils.getShowName(history.author ?? ''),
          style: metaStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final rowBody = Padding(
      padding: EdgeInsets.fromLTRB(
        isMac ? 10 : 16,
        isMac ? 9 : 12,
        trailing == null ? (isMac ? 10 : 16) : 4,
        isMac ? 9 : 12,
      ),
      child: trailing == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                trailing!,
              ],
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
                  onTap: () => _handleTap(context, history, ref),
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
        Material(
          color: selected ? selectedBg : Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context, history, ref),
            onLongPress: onLongPress,
            child: rowBody,
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
    TopicHistory topicHistory,
    InterfaceSettingsState interfaceState,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool appleCompact = false,
  }) {
    final baseFontSize = appleCompact ? 13.5 : Dimen.titleMedium;
    return Text.rich(
      TextSpan(
        text: code_utils.unescapeHtml(topicHistory.subject),
        style: textTheme.titleMedium?.copyWith(
          fontSize: baseFontSize * interfaceState.titleSizeMultiple,
          color: topicHistory.getSubjectColor() ?? textTheme.bodyLarge?.color,
          fontWeight: topicHistory.isBold()
              ? FontWeight.w600
              : (appleCompact ? FontWeight.w500 : FontWeight.normal),
          fontStyle: topicHistory.isItalic()
              ? FontStyle.italic
              : FontStyle.normal,
          decoration: topicHistory.isUnderline()
              ? TextDecoration.underline
              : null,
          height: interfaceState.lineHeight.size,
        ),
        children: [
          if (topicHistory.topicParentName?.isNotEmpty == true)
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
                    code_utils.unescapeHtml(topicHistory.topicParentName!),
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
          if (topicHistory.locked())
            TextSpan(
              text: " [锁定]",
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (topicHistory.isAssemble())
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

  void _handleTap(
    BuildContext context,
    TopicHistory topicHistory,
    WidgetRef ref,
  ) {
    ref
        .read(topicHistoryProvider.notifier)
        .insertHistory(topicHistory.createNewHistory());
    if (onTap != null) {
      onTap!();
      return;
    }
    Routes.navigateTo(
      context,
      "${Routes.TOPIC_DETAIL}?tid=${topicHistory.tid}&fid=${topicHistory.fid}&subject=${topicHistory.subject}",
    );
  }
}
