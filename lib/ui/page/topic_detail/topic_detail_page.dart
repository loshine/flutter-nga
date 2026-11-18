import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
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
  });

  final int? tid;
  final int? fid;
  final String? subject;
  final int? authorid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerKey = TopicDetailKey(tid: tid!);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(code_utils.unescapeHtml(state.subject ?? subject ?? "")),
        actions: [
          PopupMenuButton<TopicDetailMenuAction>(
            tooltip: '更多',
            onSelected: (action) => _onMenuSelected(action),
            itemBuilder: (context) => [
              for (final action in TopicDetailMenuAction.values)
                PopupMenuItem(value: action, child: Text(action.label)),
            ],
          ),
        ],
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: widgets,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: '上一页',
              icon: Icon(Icons.chevron_left),
              onPressed: hasPrevious
                  ? () => goToPage(tabController.index - 1)
                  : null,
            ),
            Tooltip(
              message: '跳转页码',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => TopicPageSelectDialog(
                      currentPage: state.currentPage,
                      maxPage: state.maxPage,
                      maxFloor: state.maxFloor,
                      pageSelectedCallback: (isPage, target) {
                        final index = isPage
                            ? target - 1
                            : (target / 20 - 1).ceil();
                        goToPage(
                          index.clamp(0, tabController.length - 1).toInt(),
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    "${state.currentPage}/${state.maxPage}",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: '下一页',
              icon: Icon(Icons.chevron_right),
              onPressed: hasNext
                  ? () => goToPage(tabController.index + 1)
                  : null,
            ),
            Spacer(flex: 1),
            // 按当前实际亮度在日间 / 夜间之间切换，图标与提示显示切换目标。
            IconButton(
              tooltip: isDark ? '切换到日间模式' : '切换到夜间模式',
              icon: Icon(
                isDark
                    ? CommunityMaterialIcons.weather_sunny
                    : CommunityMaterialIcons.weather_night,
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
              icon: Icon(CommunityMaterialIcons.heart_outline),
              selectedIcon: Icon(CommunityMaterialIcons.heart),
              onPressed: state.favouriteBusy
                  ? null
                  : () {
                      notifier
                          .toggleFavourite()
                          .then((message) {
                            if (message != null) AppToast.success(message);
                          })
                          .catchError((e) {
                            AppToast.error(e);
                          });
                    },
            ),
            IconButton(
              tooltip: '回复',
              icon: Icon(CommunityMaterialIcons.comment_outline),
              onPressed: () {
                if (fid == null && state.topic == null) return;
                Routes.navigateTo(
                  context,
                  "${Routes.TOPIC_PUBLISH}?tid=$tid&fid=${fid ?? state.topic!.fid}",
                );
              },
            ),
          ],
        ),
      ),
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
