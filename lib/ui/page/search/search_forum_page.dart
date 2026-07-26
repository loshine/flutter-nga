import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/search/search_forum_provider.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchForumPage extends HookConsumerWidget {
  const SearchForumPage(this.keyword, {super.key});

  final String keyword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final forums = ref.watch(searchForumProvider);
    final notifier = ref.read(searchForumProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.search(keyword);
        if (!context.mounted) return;
        refreshController.finishRefresh();
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    }

    useInitialRefresh(refreshController);

    return Scaffold(
      appBar: AppBar(
        title: Text("搜索板块:$keyword"),
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        child: ListView.builder(
          itemBuilder: (_, index) =>
              _buildForumWidget(context, forums[index]),
          itemCount: forums.length,
        ),
      ),
    );
  }

  Widget _buildForumWidget(BuildContext context, Forum forum) {
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
