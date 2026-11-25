import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_action_menu.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/material_tab_controller_hook.dart';
import 'package:flutter_nga/utils/nga_links.dart';
import 'package:flutter_nga/utils/route.dart';

/// 帖子详情 AppBar 溢出菜单
enum TopicDetailMenuAction {
  copyLink('复制帖子链接'),
  openInBrowser('在浏览器中打开');

  const TopicDetailMenuAction(this.label);

  final String label;
}

class TopicDetailPage extends HookConsumerWidget {
  const TopicDetailPage(
    this.tid,
    this.fid, {
    super.key,
    this.subject,
    this.authorid,
    this.embedded = false,
    this.onClose,
  });

  final int? tid;
  final int? fid;
  final String? subject;
  final int? authorid;

  /// 是否作为大屏双栏布局的右侧内嵌面板展示
  final bool embedded;

  /// 内嵌模式下关闭详情面板的回调
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerKey = (tid: tid!);
    final state = ref.watch(topicDetailProvider(providerKey));
    final notifier = ref.read(topicDetailProvider(providerKey).notifier);

    final length = state.maxPage < 1 ? 1 : state.maxPage;
    final initialIndex = (state.currentPage - 1).clamp(0, length - 1);
    final tabController = useMaterialTabController(
      initialLength: length,
      initialIndex: initialIndex,
      keys: [length],
    );

    // Only mount TopicSinglePage for pages the user has actually opened.
    final visitedPages = useState(<int>{initialIndex});

    useEffect(() {
      // Drop indices that no longer exist after maxPage shrinks/grows rebuild.
      final valid = visitedPages.value.where((i) => i < length).toSet();
      if (!valid.contains(tabController.index)) {
        valid.add(tabController.index);
      }
      if (valid.length != visitedPages.value.length ||
          !valid.containsAll(visitedPages.value)) {
        visitedPages.value = valid;
      }
      return null;
    }, [length]);

    useEffect(() {
      void listener() {
        if (tabController.indexIsChanging) return;
        final index = tabController.index;
        if (!visitedPages.value.contains(index)) {
          visitedPages.value = {...visitedPages.value, index};
        }
        notifier.setCurrentPage(index + 1);
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    void jumpToFloor(int lou) {
      if (lou <= 0) return;
      final target = (lou / 20 - 1)
          .ceil()
          .clamp(0, tabController.length - 1)
          .toInt();
      // Ensure the target page is built before animating to it.
      if (!visitedPages.value.contains(target)) {
        visitedPages.value = {...visitedPages.value, target};
      }
      tabController.animateTo(target);
    }

    final widgets = <Widget>[
      for (var i = 0; i < length; i++)
        if (visitedPages.value.contains(i))
          TopicSinglePage(
            key: ValueKey('topic-$tid-page-${i + 1}'),
            tid: tid!,
            page: i + 1,
            authorid: authorid,
            onJumpToFloor: jumpToFloor,
          )
        else
          const SizedBox.shrink(),
    ];

    void goToPage(int target) {
      if (!visitedPages.value.contains(target)) {
        visitedPages.value = {...visitedPages.value, target};
      }
      tabController.animateTo(target);
    }

    final hasPrevious = state.currentPage > 1;
    final hasNext = state.currentPage < state.maxPage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favourited = state.favourite == FavouriteStatus.favourited;
    final isApple = context.isAppleStyle;
    final isMacDesktop = context.isMacDesktopAppleStyle;

    void openPageSelector() {
      TopicPageSelectDialog.show(
        context,
        currentPage: state.currentPage,
        maxPage: state.maxPage,
        maxFloor: state.maxFloor,
        pageSelectedCallback: (isPage, target) {
          final index = isPage ? target - 1 : (target / 20 - 1).ceil();
          goToPage(index.clamp(0, tabController.length - 1).toInt());
        },
      );
    }

    void toggleFavourite() {
      notifier
          .toggleFavourite()
          .then((message) {
            AppHaptics.selectionChanged();
            if (message != null) AppToast.success(message);
          })
          .catchError((e) {
            AppToast.error(e);
          });
    }

    Future<void> openReply() async {
      if (fid == null && state.topic == null) return;
      final published = await Routes.navigateTo(
        context,
        "${Routes.TOPIC_PUBLISH}?tid=$tid&fid=${fid ?? state.topic!.fid}",
      );
      if (published == true && context.mounted) {
        notifier.notifyReplyPublished();
      }
    }

    Future<void> openAppleMoreMenu(BuildContext btnContext) async {
      final box = btnContext.findRenderObject() as RenderBox?;
      final pos = box?.localToGlobal(Offset(box.size.width, box.size.height));
      final selected = await showAppActionMenu<TopicDetailMenuAction>(
        context: context,
        globalPosition: pos,
        actions: const [
          AppMenuAction(
            value: TopicDetailMenuAction.copyLink,
            label: '复制帖子链接',
            icon: CupertinoIcons.link,
          ),
          AppMenuAction(
            value: TopicDetailMenuAction.openInBrowser,
            label: '在浏览器中打开',
            icon: CupertinoIcons.compass,
          ),
        ],
      );
      if (selected != null) _onMenuSelected(selected);
    }

    final moreActionWidget = isApple
        ? Builder(
            builder: (btnContext) => IconButton(
              tooltip: '更多',
              icon: Icon(AppIcons.more(context)),
              onPressed: () => openAppleMoreMenu(btnContext),
            ),
          )
        : PopupMenuButton<TopicDetailMenuAction>(
            tooltip: '更多',
            onSelected: (action) => _onMenuSelected(action),
            itemBuilder: (context) => [
              for (final action in TopicDetailMenuAction.values)
                PopupMenuItem(value: action, child: Text(action.label)),
            ],
          );

    // macOS 桌面阅读器：把翻页、收藏、回复、日夜间全部整合进顶部 52pt Toolbar，取消手机底栏
    if (isMacDesktop) {
      final colorScheme = Theme.of(context).colorScheme;
      return AppScaffold(
        embedded: embedded,
        title: Text(code_utils.unescapeHtml(state.subject ?? subject ?? "")),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '上一页',
                  icon: Icon(AppIcons.chevronLeft(context), size: 15),
                  onPressed: hasPrevious
                      ? () => goToPage(tabController.index - 1)
                      : null,
                ),
                Tooltip(
                  message: '跳转页码',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: openPageSelector,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        "${state.currentPage}/${state.maxPage}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '下一页',
                  icon: Icon(AppIcons.chevronRight(context), size: 15),
                  onPressed: hasNext
                      ? () => goToPage(tabController.index + 1)
                      : null,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isDark ? '切换到日间模式' : '切换到夜间模式',
            icon: Icon(
              isDark ? AppIcons.lightMode(context) : AppIcons.darkMode(context),
            ),
            onPressed: () => ref
                .read(themeProvider.notifier)
                .update(
                  context,
                  isDark ? AdaptiveThemeMode.light : AdaptiveThemeMode.dark,
                ),
          ),
          IconButton(
            tooltip: favourited ? '取消收藏' : '收藏',
            icon: Icon(
              AppIcons.favorite(context, filled: favourited),
              color: favourited ? colorScheme.primary : null,
            ),
            onPressed: state.favouriteBusy ? null : toggleFavourite,
          ),
          IconButton(
            tooltip: '回复',
            color: colorScheme.primary,
            icon: Icon(AppIcons.reply(context)),
            onPressed: openReply,
          ),
          moreActionWidget,
          if (embedded && onClose != null)
            IconButton(
              tooltip: '关闭',
              icon: Icon(AppIcons.close(context)),
              onPressed: onClose,
            ),
        ],
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: widgets,
        ),
      );
    }

    final toolbarRow = ReadableWidth(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: '上一页',
            icon: Icon(AppIcons.chevronLeft(context)),
            onPressed: hasPrevious
                ? () => goToPage(tabController.index - 1)
                : null,
          ),
          Tooltip(
            message: '跳转页码',
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: openPageSelector,
              child: Text(
                "${state.currentPage}/${state.maxPage}",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: '下一页',
            icon: Icon(AppIcons.chevronRight(context)),
            onPressed: hasNext ? () => goToPage(tabController.index + 1) : null,
          ),
          const Spacer(flex: 1),
          // 按当前实际亮度在日间 / 夜间之间切换，图标与提示显示切换目标。
          IconButton(
            tooltip: isDark ? '切换到日间模式' : '切换到夜间模式',
            icon: Icon(
              isDark ? AppIcons.lightMode(context) : AppIcons.darkMode(context),
            ),
            onPressed: () => ref
                .read(themeProvider.notifier)
                .update(
                  context,
                  isDark ? AdaptiveThemeMode.light : AdaptiveThemeMode.dark,
                ),
          ),
          IconButton(
            tooltip: favourited ? '取消收藏' : '收藏',
            isSelected: favourited,
            icon: Icon(AppIcons.favorite(context)),
            selectedIcon: Icon(
              AppIcons.favorite(context, filled: true),
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: state.favouriteBusy ? null : toggleFavourite,
          ),
          const SizedBox(width: 4),
          isApple
              ? IconButton(
                  tooltip: '回复',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icon(AppIcons.reply(context)),
                  onPressed: openReply,
                )
              : IconButton.filledTonal(
                  tooltip: '回复',
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: openReply,
                ),
        ],
      ),
    );

    return AppScaffold(
      embedded: embedded,
      title: Text(code_utils.unescapeHtml(state.subject ?? subject ?? "")),
      actions: [
        moreActionWidget,
        if (embedded && onClose != null)
          IconButton(
            tooltip: '关闭',
            icon: Icon(AppIcons.close(context)),
            onPressed: onClose,
          ),
      ],
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: widgets,
      ),
      bottomNavigationBar: isApple
          ? LiquidGlassSurface(
              variant: LiquidGlassVariant.bar,
              borderRadius: BorderRadius.zero,
              showShadow: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant
                          .withValues(alpha: 0.65),
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: toolbarRow,
                    ),
                  ),
                ),
              ),
            )
          : BottomAppBar(child: toolbarRow),
    );
  }

  void _onMenuSelected(TopicDetailMenuAction action) {
    final url = topicWebUrl(tid!);
    switch (action) {
      case TopicDetailMenuAction.copyLink:
        Clipboard.setData(ClipboardData(text: url))
            .then((_) => AppToast.success('已复制帖子链接'));
      case TopicDetailMenuAction.openInBrowser:
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).then((
          opened,
        ) {
          if (!opened) AppToast.error('无法打开浏览器');
        }, onError: (Object e) => AppToast.error('无法打开浏览器'));
    }
  }
}
