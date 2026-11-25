import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/search/search_forum_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
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

    return AppScaffold(
      title: Text("搜索板块:$keyword"),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        child: ListStatusSwitcher(
          status: loadStatus,
          isEmpty: forums.isEmpty,
          emptyMessage: '暂无匹配的版块',
          emptyIcon: Icons.search_off_outlined,
          onRetry: refreshController.callRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= kCompactBreakpoint) {
                final bottomPadding = MediaQuery.paddingOf(context).bottom;
                final padding = readableListPadding(
                  constraints.maxWidth,
                  base: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
                  maxWidth: 1120,
                );
                return GridView.builder(
                  padding: padding,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 64,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: forums.length,
                  itemBuilder: (_, index) =>
                      _buildForumCard(context, forums[index]),
                );
              }
              return ReadableListPadding(
                builder: (context, padding) => ListView.builder(
                  padding: padding,
                  itemBuilder: (_, index) =>
                      _buildForumWidget(context, forums[index]),
                  itemCount: forums.length,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForumCard(BuildContext context, Forum forum) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(Dimen.radiusM),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openForum(context, forum),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.forum_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  forum.name,
                  style: textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
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
          Padding(padding: const EdgeInsets.all(16), child: Text(forum.name)),
          const Divider(height: 1),
        ],
      ),
      onTap: () => _openForum(context, forum),
    );
  }

  void _openForum(BuildContext context, Forum forum) {
    Routes.navigateTo(
      context,
      "${Routes.FORUM_DETAIL}?fid=${forum.fid}&name=${forum.name}",
    );
  }
}
