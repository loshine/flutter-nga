import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/topic/topic_detail_store.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class TopicDetailPage extends StatelessWidget {
  const TopicDetailPage(this.tid, this.fid, {this.subject, Key? key})
      : super(key: key);

  final int? tid;
  final int? fid;
  final String? subject;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => TopicDetailStore()),
      ],
      child: _TopicDetailPage(
        tid,
        fid,
        subject: subject,
      ),
    );
  }
}

class _TopicDetailPage extends StatefulWidget {
  const _TopicDetailPage(this.tid, this.fid, {this.subject, Key? key})
      : super(key: key);

  final int? tid;
  final int? fid;
  final String? subject;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<_TopicDetailPage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TopicDetailStore>(context);
    final firstPage = TopicSinglePage(
      tid: widget.tid!,
      page: 1,
    );
    return Observer(
      builder: (_) {
        List<Widget> widgets = [];
        _tabController = TabController(
          vsync: this,
          length: store.maxPage,
          initialIndex: store.currentPage - 1,
        );
        _tabController!.addListener(() {
          store.setCurrentPage(_tabController!.index + 1);
        });
        for (int i = 0; i < store.maxPage; i++) {
          if (i == 0) {
            widgets.add(firstPage);
          } else {
            widgets.add(TopicSinglePage(
              tid: widget.tid!,
              page: i + 1,
            ));
          }
        }
        return Scaffold(
          appBar: AppBar(title: Text(codeUtils.unescapeHtml(store.subject))),
          body: TabBarView(
            controller: _tabController,
            children: widgets,
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).primaryColor,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: store.currentPage != 1 ? 1 : 0.3,
                    child: IconButton(
                      icon: Icon(Icons.chevron_left),
                      color: Colors.white,
                      onPressed: () {
                        if (store.currentPage != 1) {
                          _tabController!.animateTo(_tabController!.index - 1);
                        }
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => TopicPageSelectDialog(
                          currentPage: store.currentPage,
                          maxPage: store.maxPage,
                          maxFloor: store.maxFloor,
                        ),
                      );
                    },
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${store.currentPage}/${store.maxPage}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: store.maxPage != store.currentPage ? 1 : 0.3,
                    child: IconButton(
                      icon: Icon(Icons.chevron_right),
                      color: Colors.white,
                      onPressed: () {
                        if (store.maxPage != store.currentPage) {
                          _tabController!.animateTo(_tabController!.index + 1);
                        }
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.weather_night),
                    color: Colors.white,
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
                    color: Colors.white,
                    onPressed: _addFavourite,
                  ),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.comment_outline),
                    color: Colors.white,
                    onPressed: () {
                      if (widget.fid == null && store.topic == null) return;
                      Routes.navigateTo(context,
                          "${Routes.TOPIC_PUBLISH}?tid=${widget.tid}&fid=${widget.fid != null ? widget.fid : store.topic!.fid}");
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  _addFavourite() {
    final store = Provider.of<TopicDetailStore>(context, listen: false);
    store.addFavourite(widget.tid).then((message) {
      Fluttertoast.showToast(msg: message!);
    }).catchError((e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: e.message);
      } else {
        Fluttertoast.showToast(msg: e.toString());
      }
    });
  }
}
