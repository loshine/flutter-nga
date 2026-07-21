import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final tabController = useTabController(
      initialLength: length,
      initialIndex: initialIndex,
      keys: [length],
    );

    useEffect(() {
      void listener() {
        if (tabController.indexIsChanging) return;
        notifier.setCurrentPage(tabController.index + 1);
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    void jumpToFloor(int lou) {
      if (lou <= 0) return;
      final target =
          (lou / 20 - 1).ceil().clamp(0, tabController.length - 1).toInt();
      tabController.animateTo(target);
    }

    final widgets = <Widget>[
      for (var i = 0; i < length; i++)
        TopicSinglePage(
          tid: tid!,
          page: i + 1,
          authorid: authorid,
          onJumpToFloor: jumpToFloor,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          code_utils.unescapeHtml(state.subject ?? subject ?? ""),
        ),
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
            Opacity(
              opacity: state.currentPage != 1 ? 1 : 0.3,
              child: IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  if (state.currentPage != 1) {
                    tabController.animateTo(tabController.index - 1);
                  }
                },
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => TopicPageSelectDialog(
                    currentPage: state.currentPage,
                    maxPage: state.maxPage,
                    maxFloor: state.maxFloor,
                    pageSelectedCallback: (isPage, target) {
                      if (isPage) {
                        tabController.animateTo(target - 1);
                      } else {
                        tabController.animateTo((target / 20 - 1).ceil());
                      }
                    },
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  "${state.currentPage}/${state.maxPage}",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ),
            Opacity(
              opacity: state.maxPage != state.currentPage ? 1 : 0.3,
              child: IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  if (state.maxPage != state.currentPage) {
                    tabController.animateTo(tabController.index + 1);
                  }
                },
              ),
            ),
            Spacer(flex: 1),
            IconButton(
              icon: Icon(CommunityMaterialIcons.weather_night),
              onPressed: () async {
                AdaptiveTheme.of(context).toggleThemeMode();
                final mode = await AdaptiveTheme.getThemeMode();
                String modeName;
                if (mode == AdaptiveThemeMode.light) {
                  modeName = "日间模式";
                } else if (mode == AdaptiveThemeMode.dark) {
                  modeName = "黑暗模式";
                } else {
                  modeName = "跟随系统";
                }
                AppToast.info("已切换到 $modeName");
              },
            ),
            IconButton(
              icon: Icon(CommunityMaterialIcons.heart_outline),
              onPressed: () {
                notifier.addFavourite(tid).then((message) {
                  AppToast.success(message.toString());
                }).catchError((e) {
                  AppToast.error(e.message);
                });
              },
            ),
            IconButton(
              icon: Icon(CommunityMaterialIcons.comment_outline),
              onPressed: () {
                if (fid == null && state.topic == null) return;
                Routes.navigateTo(
                  context,
                  "${Routes.TOPIC_PUBLISH}?tid=$tid&fid=${fid != null ? fid : state.topic!.fid}",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
