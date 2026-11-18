import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/search/search_forum_provider.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/route.dart';

class SearchForumPage extends HookConsumerWidget {
  const SearchForumPage(this.keyword, {super.key});

  final String keyword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final loadStatus = useListLoadStatus();
    final forums = ref.watch(searchForumProvider);
    final notifier = ref.read(searchForumProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.search(keyword);
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref.read(searchForumProvider).isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
      }
    }

    useInitialRefresh(refreshController);

    return Scaffold(
      appBar: AppBar(title: Text("搜索板块:$keyword")),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        child: ListStatusSwitcher(
          status: loadStatus,
          isEmpty: forums.isEmpty,
          emptyMessage: '暂无匹配的版块',
          emptyIcon: Icons.search_off_outlined,
          onRetry: refreshController.callRefresh,
          child: ReadableListPadding(
            builder: (context, padding) => ListView.builder(
              padding: padding,
              itemBuilder: (_, index) =>
                  _buildForumWidget(context, forums[index]),
              itemCount: forums.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForumWidget(BuildContext context, Forum forum) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.all(16), child: Text(forum.name)),
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
