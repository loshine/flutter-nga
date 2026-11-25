import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoIcons, CupertinoSearchTextField;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/page/settings/settings_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_action_menu.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/route.dart';

/// macOS / iPadOS 横屏三栏工作区当前选中的导航目标。
sealed class _WorkspaceDestination {
  const _WorkspaceDestination();
}

final class _AllForumsDestination extends _WorkspaceDestination {
  const _AllForumsDestination({this.openedForum});
  final Forum? openedForum;
}

final class _FavouriteForumDestination extends _WorkspaceDestination {
  const _FavouriteForumDestination(this.forum);
  final Forum forum;
}

final class _FavouriteTopicsDestination extends _WorkspaceDestination {
  const _FavouriteTopicsDestination();
}

final class _HistoryDestination extends _WorkspaceDestination {
  const _HistoryDestination();
}

final class _ConversationsDestination extends _WorkspaceDestination {
  const _ConversationsDestination();
}

final class _NotificationsDestination extends _WorkspaceDestination {
  const _NotificationsDestination();
}

/// macOS / iPadOS 原生三栏工作区外壳：
/// - 左侧常驻 Source List 侧边栏（顶部 52pt 与系统红绿灯同行、内嵌搜索框、直接展开收藏版块、
///   发现、我的模块、底部账号栏与设置 Sheet 入口）；
/// - 中栏 + 右栏承载对应的版块帖子流/阅读器、收藏/历史、私信/提醒，侧边栏始终常驻不消失。
class AppleWorkspaceShell extends HookConsumerWidget {
  const AppleWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarCollapsed = useState(false);
    final favouritesExpanded = useState(true);
    final allForumsTabIndex = useState(0);
    final searchController = useTextEditingController();
    final destination = useState<_WorkspaceDestination>(
      const _AllForumsDestination(),
    );
    final autoSelectedInitial = useRef(false);

    usePostFrameEffect(() {
      ref
          .read(favouriteForumListProvider.notifier)
          .refresh()
          .catchError((_) {});
      ref.read(forumCategoryListProvider.notifier).ensureLoaded();
    });

    final favForumsState = ref.watch(favouriteForumListProvider);
    final favForums = favForumsState.forums;
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    ref.watch(unreadCountProvider);
    final unread = ref
        .read(unreadCountProvider.notifier)
        .countsFor(userInfo?.uid);

    // 首次加载到收藏版块时自动打开第一个收藏版块，进应用即可阅读
    useEffect(() {
      if (!autoSelectedInitial.value &&
          favForums.isNotEmpty &&
          destination.value is _AllForumsDestination) {
        autoSelectedInitial.value = true;
        destination.value = _FavouriteForumDestination(favForums.first);
      }
      return null;
    }, [favForums.length]);

    final colorScheme = Theme.of(context).colorScheme;
    final trafficLightInset = context.macTitlebarInset;
    final hasTrafficLights = trafficLightInset > 0;

    void openSettingsSheet() {
      showDialog<void>(
        context: context,
        builder: (sheetContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 620),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: ScaffoldMessenger(
                  child: SettingsPage(
                    embedded: true,
                    onClose: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final menuHandlerRef = useRef<WorkspaceMenuRouteHandler?>(null);
    menuHandlerRef.value = (path) {
      switch (path) {
        case Routes.FAVOURITE_TOPICS:
          destination.value = const _FavouriteTopicsDestination();
          return true;
        case Routes.TOPIC_HISTORY:
          destination.value = const _HistoryDestination();
          return true;
        case Routes.CONVERSATIONS:
          destination.value = const _ConversationsDestination();
          return true;
        case Routes.NOTIFICATIONS:
          destination.value = const _NotificationsDestination();
          return true;
        case Routes.SETTINGS:
          openSettingsSheet();
          return true;
        default:
          return false;
      }
    };
    useEffect(() {
      final controller = ref.read(workspaceMenuControllerProvider);
      bool dispatch(String path) => menuHandlerRef.value?.call(path) ?? false;
      controller.register(dispatch);
      return () => controller.unregister(dispatch);
    }, const []);

    void submitQuickSearch(String raw) {
      final keyword = raw.trim();
      if (keyword.isEmpty) {
        Routes.navigateTo(context, Routes.SEARCH);
        return;
      }
      Routes.navigateTo(
        context,
        '${Routes.SEARCH_TOPIC_LIST}?keyword=${code_utils.encodeParam(keyword)}&content=0',
      );
    }

    Future<void> confirmRemoveFavouriteForum(Forum forum) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => M3ConfirmDialog(
          title: '移除收藏版面',
          content: '确定从收藏版块中移除「${forum.name}」吗？',
          confirmText: '移除',
          destructive: true,
        ),
      );
      if (confirmed != true) return;
      try {
        await ref.read(favouriteForumListProvider.notifier).delete(forum);
        if (destination.value
            case _FavouriteForumDestination(forum: final current)
            when current.identity == forum.identity) {
          destination.value = const _AllForumsDestination();
        }
      } catch (e) {
        AppToast.error(e);
      }
    }

    final sidebarAnimDuration = Motion.resolveDuration(
      context,
      const Duration(milliseconds: 240),
    );

    // 侧边栏折叠时，在右侧工作区顶栏左侧平滑滑出展开按钮与红绿灯安全区；
    // 全屏模式下 trafficLightInset 自动归 0，不留多余空白。
    Widget? collapsedToggleLeading({Widget? extra}) {
      return AnimatedSize(
        duration: sidebarAnimDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            if (sidebarCollapsed.value) ...[
              if (hasTrafficLights) SizedBox(width: trafficLightInset),
              IconButton(
                tooltip: '展开侧边栏',
                icon: Icon(
                  AppIcons.sidebar(context),
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => sidebarCollapsed.value = false,
              ),
            ],
            ?extra,
          ],
        ),
      );
    }

    Widget buildMainWorkspace() {
      return switch (destination.value) {
        _FavouriteForumDestination(:final forum) => ForumDetailPage(
          key: ValueKey('workspace-fav-forum-${forum.identity.storageKey}'),
          fid: forum.fid,
          name: forum.name,
          type: forum.type,
          embedded: true,
          leading: collapsedToggleLeading(),
        ),
        _AllForumsDestination(:final openedForum) when openedForum != null =>
          ForumDetailPage(
            key: ValueKey(
              'workspace-dir-forum-${openedForum.identity.storageKey}',
            ),
            fid: openedForum.fid,
            name: openedForum.name,
            type: openedForum.type,
            embedded: true,
            leading: collapsedToggleLeading(
              extra: IconButton(
                tooltip: '返回全部版块',
                icon: Icon(
                  CupertinoIcons.back,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    destination.value = const _AllForumsDestination(),
              ),
            ),
          ),
        _AllForumsDestination() => AppScaffold(
          embedded: true,
          leading: collapsedToggleLeading(),
          title: const Text('全部版块'),
          actions: [
            IconButton(
              tooltip: '高级搜索',
              icon: Icon(AppIcons.search(context), size: 17),
              onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
            ),
          ],
          body: ForumGroupTabsPage(
            initialIndex: allForumsTabIndex.value,
            onTabChanged: (index) => allForumsTabIndex.value = index,
            onForumTap: (forum) =>
                destination.value = _AllForumsDestination(openedForum: forum),
          ),
        ),
        _FavouriteTopicsDestination() => FavouriteTopicListPage(
          key: const ValueKey('workspace-fav-topics'),
          embedded: true,
          leading: collapsedToggleLeading(),
        ),
        _HistoryDestination() => TopicHistoryListPage(
          key: const ValueKey('workspace-history'),
          embedded: true,
          leading: collapsedToggleLeading(),
        ),
        _ConversationsDestination() => ConversationListPage(
          key: const ValueKey('workspace-conversations'),
          embedded: true,
          leading: collapsedToggleLeading(),
        ),
        _NotificationsDestination() => NotificationListPage(
          key: const ValueKey('workspace-notifications'),
          embedded: true,
          leading: collapsedToggleLeading(),
        ),
      };
    }

    final viewPadding = MediaQuery.paddingOf(context);
    final leftSafeInset = viewPadding.left;
    final bottomSafeInset = viewPadding.bottom;
    final sidebarWidth = 244.0 + leftSafeInset;
    final totalSidebarWidth = sidebarWidth + 0.5;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        children: [
          // 双栏 / 三栏平滑推拉动画：ClipRect + OverflowBox 保证收起过程中内部不挤压折行
          ClipRect(
            child: AnimatedContainer(
              duration: sidebarAnimDuration,
              curve: Curves.easeOutCubic,
              width: sidebarCollapsed.value ? 0 : totalSidebarWidth,
              child: IgnorePointer(
                ignoring: sidebarCollapsed.value,
                child: ExcludeSemantics(
                  excluding: sidebarCollapsed.value,
                  child: OverflowBox(
                    alignment: Alignment.centerRight,
                    minWidth: totalSidebarWidth,
                    maxWidth: totalSidebarWidth,
                    child: Row(
                      children: [
                        SizedBox(
                          width: sidebarWidth,
                          child: ColoredBox(
                            color: colorScheme.surfaceContainerLow,
                            child: Padding(
                              padding: EdgeInsets.only(left: leftSafeInset),
                              child: Column(
                                children: [
                                  // 顶部 52pt 与 macOS 红绿灯同一水平线
                                  SizedBox(
                                    height: 52 + viewPadding.top,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: viewPadding.top,
                                        left: hasTrafficLights
                                            ? trafficLightInset + 4
                                            : 12,
                                        right: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 2,
                                        children: [
                                          if (!hasTrafficLights)
                                            Text(
                                              'FNGA',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                          const Spacer(),
                                          IconButton(
                                            tooltip: '添加自定义版面',
                                            icon: Icon(
                                              AppIcons.add(context),
                                              size: 16,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () => showDialog<void>(
                                              context: context,
                                              builder: (_) =>
                                                  const CustomForumDialog(),
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: '收起侧边栏',
                                            icon: Icon(
                                              AppIcons.sidebar(context),
                                              size: 16,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () =>
                                                sidebarCollapsed.value = true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 紧凑内嵌搜索框
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      0,
                                      12,
                                      10,
                                    ),
                                    child: SizedBox(
                                      height: 30,
                                      child: CupertinoSearchTextField(
                                        controller: searchController,
                                        placeholder: '搜索主题…',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurface,
                                        ),
                                        placeholderStyle: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.75),
                                        ),
                                        prefixInsets:
                                            const EdgeInsetsDirectional.fromSTEB(
                                              7,
                                              0,
                                              4,
                                              0,
                                            ),
                                        itemSize: 15,
                                        borderRadius: BorderRadius.circular(8),
                                        onSubmitted: submitQuickSearch,
                                      ),
                                    ),
                                  ),
                                  // 可滚动 Source List 源列表
                                  Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        0,
                                        10,
                                        12,
                                      ),
                                      children: [
                                        _SidebarSectionHeader(
                                          title: '我的',
                                          colorScheme: colorScheme,
                                        ),
                                        _SidebarRow(
                                          icon: Icon(
                                            AppIcons.bookmark(context),
                                            size: 16,
                                          ),
                                          label: '贴子收藏',
                                          selected:
                                              destination.value
                                                  is _FavouriteTopicsDestination,
                                          onTap: () => destination.value =
                                              const _FavouriteTopicsDestination(),
                                        ),
                                        _SidebarRow(
                                          icon: Icon(
                                            AppIcons.history(context),
                                            size: 16,
                                          ),
                                          label: '浏览历史',
                                          selected:
                                              destination.value
                                                  is _HistoryDestination,
                                          onTap: () => destination.value =
                                              const _HistoryDestination(),
                                        ),
                                        _SidebarRow(
                                          icon: Icon(
                                            AppIcons.mail(context),
                                            size: 16,
                                          ),
                                          label: '短消息',
                                          badgeCount: unread.messages,
                                          selected:
                                              destination.value
                                                  is _ConversationsDestination,
                                          onTap: () => destination.value =
                                              const _ConversationsDestination(),
                                        ),
                                        _SidebarRow(
                                          icon: Icon(
                                            AppIcons.notifications(context),
                                            size: 16,
                                          ),
                                          label: '提醒信息',
                                          badgeCount: unread.notifications,
                                          selected:
                                              destination.value
                                                  is _NotificationsDestination,
                                          onTap: () => destination.value =
                                              const _NotificationsDestination(),
                                        ),
                                        const SizedBox(height: 12),
                                        _SidebarSectionHeader(
                                          title: '版块',
                                          colorScheme: colorScheme,
                                        ),
                                        _SidebarRow(
                                          icon: Icon(
                                            AppIcons.grid(context),
                                            size: 16,
                                          ),
                                          label: '全部版块',
                                          selected:
                                              destination.value
                                                  is _AllForumsDestination,
                                          onTap: () => destination.value =
                                              const _AllForumsDestination(),
                                        ),
                                        const SizedBox(height: 12),
                                        _SidebarSectionHeader(
                                          title: '收藏版块 (${favForums.length})',
                                          colorScheme: colorScheme,
                                          collapsible: true,
                                          expanded: favouritesExpanded.value,
                                          onToggle: () =>
                                              favouritesExpanded.value =
                                                  !favouritesExpanded.value,
                                        ),
                                        if (favouritesExpanded.value) ...[
                                          if (favForums.isEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              child: Text(
                                                '暂无收藏版块',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            )
                                          else
                                            for (final forum in favForums)
                                              _SidebarRow(
                                                icon: _SidebarForumIcon(
                                                  forum: forum,
                                                ),
                                                label: forum.name,
                                                selected: switch (destination
                                                    .value) {
                                                  _FavouriteForumDestination(
                                                    forum: final current,
                                                  ) =>
                                                    current.identity ==
                                                        forum.identity,
                                                  _ => false,
                                                },
                                                onTap: () => destination.value =
                                                    _FavouriteForumDestination(
                                                      forum,
                                                    ),
                                                onLongPress: () async {
                                                  final act =
                                                      await showAppActionMenu<
                                                        String
                                                      >(
                                                        context: context,
                                                        title: forum.name,
                                                        actions: [
                                                          AppMenuAction(
                                                            value: 'remove',
                                                            label: '移除收藏',
                                                            icon:
                                                                AppIcons.delete(
                                                                  context,
                                                                ),
                                                            destructive: true,
                                                          ),
                                                        ],
                                                      );
                                                  if (act == 'remove') {
                                                    await confirmRemoveFavouriteForum(
                                                      forum,
                                                    );
                                                  }
                                                },
                                                onSecondaryTapDown: (details) async {
                                                  final act =
                                                      await showAppActionMenu<
                                                        String
                                                      >(
                                                        context: context,
                                                        globalPosition: details
                                                            .globalPosition,
                                                        actions: [
                                                          AppMenuAction(
                                                            value: 'remove',
                                                            label: '移除收藏',
                                                            icon:
                                                                AppIcons.delete(
                                                                  context,
                                                                ),
                                                            destructive: true,
                                                          ),
                                                        ],
                                                      );
                                                  if (act == 'remove') {
                                                    await confirmRemoveFavouriteForum(
                                                      forum,
                                                    );
                                                  }
                                                },
                                              ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // 底部固定账号栏 + 设置 Sheet 按钮
                                  Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      10,
                                      8,
                                      8,
                                      10 + bottomSafeInset,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: () {
                                              if (userInfo != null) {
                                                Routes.navigateTo(
                                                  context,
                                                  '${Routes.USER}?uid=${userInfo.uid}',
                                                );
                                              } else {
                                                Routes.navigateTo(
                                                  context,
                                                  Routes.LOGIN,
                                                ).then(
                                                  (_) => ref
                                                      .read(
                                                        homeDrawerHeaderProvider
                                                            .notifier,
                                                      )
                                                      .refresh(),
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  AvatarWidget(
                                                    userInfo?.avatar,
                                                    size: 26,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      userInfo?.username ??
                                                          '点击登录',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: colorScheme
                                                            .onSurface,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: '偏好设置 (⌘,)',
                                          icon: Icon(
                                            AppIcons.settings(context),
                                            size: 17,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          onPressed: openSettingsSheet,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 0.5,
                          thickness: 0.5,
                          color: colorScheme.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 主工作区（中栏 + 右栏）
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: !sidebarCollapsed.value,
              child: buildMainWorkspace(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionHeader extends StatelessWidget {
  const _SidebarSectionHeader({
    required this.title,
    required this.colorScheme,
    this.collapsible = false,
    this.expanded = true,
    this.onToggle,
  });

  final String title;
  final ColorScheme colorScheme;
  final bool collapsible;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (collapsible)
            Icon(
              expanded
                  ? CupertinoIcons.chevron_down
                  : CupertinoIcons.chevron_forward,
              size: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
    if (!collapsible) return row;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onToggle,
      child: row,
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.onLongPress,
    this.onSecondaryTapDown,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onSecondaryTapDown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTouchSidebar = !context.isMacDesktopAppleStyle;
    final bg = selected ? colorScheme.primary : Colors.transparent;
    final fg = selected ? colorScheme.onPrimary : colorScheme.onSurface;
    final iconColor = selected ? colorScheme.onPrimary : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: GestureDetector(
        onSecondaryTapDown: onSecondaryTapDown,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(7),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: isTouchSidebar ? 10 : 6,
              ),
              child: Row(
                children: [
                  IconTheme(
                    data: IconThemeData(color: iconColor, size: 16),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.onPrimary.withValues(alpha: 0.22)
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.14,
                              ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarForumIcon extends StatelessWidget {
  const _SidebarForumIcon({required this.forum});

  final Forum forum;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: forum.getIconUrl(),
        width: 18,
        height: 18,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Image.asset('images/default_forum_icon.png', width: 18, height: 18),
        errorWidget: (_, _, _) =>
            Image.asset('images/default_forum_icon.png', width: 18, height: 18),
      ),
    );
  }
}
