import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/search/search_forum_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchForumPage extends ConsumerStatefulWidget {
  const SearchForumPage(this.keyword, {super.key});

  final String keyword;

  @override
  ConsumerState<SearchForumPage> createState() => _SearchForumState();
}

class _SearchForumState extends ConsumerState<SearchForumPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(searchForumProvider.notifier));
      }
    });
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
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        child: ListView.builder(
          itemBuilder: (_, index) => _buildForumWidget(forums[index]),
          itemCount: forums.length,
        ),
      ),
    );
  }

  Future<void> _onRefresh(SearchForumNotifier notifier) async {
    try {
      await notifier.search(widget.keyword);
      if (!mounted) return;
      _refreshController.finishRefresh();
    } catch (_) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
    }
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
