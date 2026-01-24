import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/search/search_forum_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchForumPage extends ConsumerStatefulWidget {
  const SearchForumPage(this.keyword, {super.key});

  final String keyword;

  @override
  ConsumerState<SearchForumPage> createState() => _SearchForumState();
}

class _SearchForumState extends ConsumerState<SearchForumPage> {
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
    final forums = ref.watch(searchForumProvider);
    final notifier = ref.read(searchForumProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("搜索板块:${widget.keyword}"),
      ),
      body: SmartRefresher(
        onRefresh: () => _onRefresh(notifier),
        enablePullUp: false,
        controller: _refreshController,
        child: ListView.builder(
          itemBuilder: (_, index) => _buildForumWidget(forums[index]),
          itemCount: forums.length,
        ),
      ),
    );
  }

  void _onRefresh(SearchForumNotifier notifier) {
    notifier
        .search(widget.keyword)
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((_) {
      _refreshController.refreshFailed();
      return <Forum>[];
    });
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
        "&name=${forum.name}",
      ),
    );
  }
}
