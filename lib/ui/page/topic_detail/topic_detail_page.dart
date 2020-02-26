import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/store/topic_detail_store.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_single_page.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage(this.tid, this.fid, {this.subject, Key key})
      : super(key: key);

  final int tid;
  final int fid;
  final String subject;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetailPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  final _store = TopicDetailStore();

  @override
  Widget build(BuildContext context) {
    final firstPage = TopicSinglePage(
      tid: widget.tid,
      page: 1,
      totalCommentList: _store.commentList,
      onLoadComplete: _onLoadComplete,
    );
    return Observer(
      builder: (_) {
        List<Widget> widgets = [];
        _tabController = TabController(
          vsync: this,
          length: _store.maxPage,
          initialIndex: _store.currentPage - 1,
        );
        _tabController.addListener(() {
          _store.setCurrentPage(_tabController.index + 1);
        });
        for (int i = 0; i < _store.maxPage; i++) {
          if (i == 0) {
            widgets.add(firstPage);
          } else {
            widgets.add(TopicSinglePage(
              tid: widget.tid,
              page: i + 1,
              totalCommentList: _store.commentList,
              onLoadComplete: _onLoadComplete,
            ));
          }
        }
        return Scaffold(
          appBar: AppBar(title: Text(codeUtils.unescapeHtml(widget.subject))),
          body: TabBarView(
            controller: _tabController,
            children: widgets,
          ),
          bottomNavigationBar: BottomAppBar(
            color: Palette.colorPrimary,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: _store.currentPage != 1 ? 1 : 0.3,
                    child: IconButton(
                      icon: Icon(Icons.chevron_left),
                      color: Colors.white,
                      onPressed: () {
                        if (_store.currentPage != 1) {
                          _tabController.animateTo(_tabController.index - 1);
                        }
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              "${_store.currentPage}/${_store.maxPage}",
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
                    opacity: _store.maxPage != _store.currentPage ? 1 : 0.3,
                    child: IconButton(
                      icon: Icon(Icons.chevron_right),
                      color: Colors.white,
                      onPressed: () {
                        if (_store.maxPage != _store.currentPage) {
                          _tabController.animateTo(_tabController.index + 1);
                        }
                      },
                    ),
                  ),
                  Spacer(flex: 1),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.weather_night),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.heart_outline),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(CommunityMaterialIcons.comment_outline),
                    color: Colors.white,
                    onPressed: () => Routes.navigateTo(context,
                        "${Routes.TOPIC_PUBLISH}?tid=${widget.tid}&fid=${widget.fid}"),
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
    _tabController.dispose();
    super.dispose();
  }

  _onLoadComplete(int maxPage, List<Reply> commentList) {
    _store.setMaxPage(maxPage);
    _store.mergeCommentList(commentList);
  }
}
