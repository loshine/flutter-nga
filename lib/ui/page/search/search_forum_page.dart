import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/store/search/search_forum_store.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchForumPage extends StatefulWidget {
  const SearchForumPage(this.keyword, {Key? key}) : super(key: key);

  final String keyword;

  @override
  _SearchForumState createState() => _SearchForumState();
}

class _SearchForumState extends State<SearchForumPage> {
  final _store = SearchForumStore();
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索板块:${widget.keyword}"),
      ),
      body: Observer(
        builder: (_) => SmartRefresher(
          onRefresh: _onRefresh,
          enablePullUp: false,
          controller: _refreshController,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemBuilder: (_, index) => _buildForumWidget(_store.forums[index]),
            itemCount: _store.forums.length,
          ),
        ),
      ),
    );
  }

  _onRefresh() {
    _store
        .search(widget.keyword)
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((_) => _refreshController.refreshFailed());
  }

  Widget _buildForumWidget(Forum forum) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(forum.name),
          ),
          Divider(height: 1),
        ],
      ),
      onTap: () => Routes.navigateTo(
          context,
          "${Routes.FORUM_DETAIL}?fid=${forum.fid}"
          "&name=${fluroCnParamsEncode(forum.name)}"
//        "&type=${widget.forum.type}",
          ),
    );
  }
}
