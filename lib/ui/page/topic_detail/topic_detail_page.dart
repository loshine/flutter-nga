import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicDetailPage extends ConsumerStatefulWidget {
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
  ConsumerState<TopicDetailPage> createState() => _TopicDetailState();
}

class _TopicDetailState extends ConsumerState<TopicDetailPage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicDetailProvider);
    final notifier = ref.read(topicDetailProvider.notifier);
    final firstPage = TopicSinglePage(
      tid: widget.tid!,
      page: 1,
      authorid: widget.authorid,
    );

    List<Widget> widgets = [];
    _tabController = TabController(
      vsync: this,
      length: state.maxPage,
      initialIndex: state.currentPage - 1,
    );
    _tabController!.addListener(() {
      notifier.setCurrentPage(_tabController!.index + 1);
    });
    for (int i = 0; i < state.maxPage; i++) {
      if (i == 0) {
        widgets.add(firstPage);
      } else {
        widgets.add(TopicSinglePage(
          tid: widget.tid!,
          page: i + 1,
          authorid: widget.authorid,
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(code_utils.unescapeHtml(state.subject ?? ""))),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
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
                    _tabController!.animateTo(_tabController!.index - 1);
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
                        _tabController!.animateTo(target - 1);
                      } else {
                        _tabController!.animateTo((target / 20 - 1).ceil());
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
                    _tabController!.animateTo(_tabController!.index + 1);
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
                Fluttertoast.showToast(msg: "已切换到 $modeName");
              },
            ),
            IconButton(
              icon: Icon(CommunityMaterialIcons.heart_outline),
              onPressed: _addFavourite,
            ),
            IconButton(
              icon: Icon(CommunityMaterialIcons.comment_outline),
              onPressed: () {
                if (widget.fid == null && state.topic == null) return;
                Routes.navigateTo(
                  context,
                  "${Routes.TOPIC_PUBLISH}?tid=${widget.tid}&fid=${widget.fid != null ? widget.fid : state.topic!.fid}",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  _addFavourite() {
    final notifier = ref.read(topicDetailProvider.notifier);
    notifier.addFavourite(widget.tid).then((message) {
      Fluttertoast.showToast(msg: message.toString());
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.message);
    });
  }
}
