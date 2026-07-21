import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavouriteTopicListPage extends ConsumerStatefulWidget {
  const FavouriteTopicListPage({super.key});

  @override
  ConsumerState<FavouriteTopicListPage> createState() =>
      _FavouriteTopicListState();
}

class _FavouriteTopicListState extends ConsumerState<FavouriteTopicListPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(favouriteTopicListProvider.notifier));
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
    final state = ref.watch(favouriteTopicListProvider);
    final notifier = ref.read(favouriteTopicListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('贴子收藏')),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildBody(FavouriteTopicListState state,
      FavouriteTopicListNotifier notifier) {
    return EasyRefresh(
      controller: _refreshController,
      onRefresh: () => _onRefresh(notifier),
      onLoad: state.enablePullUp ? () => _onLoading(notifier) : null,
      child: ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) => TopicListItemWidget(
          topic: state.list[index],
          onLongPress: () => _showDeleteDialog(notifier, state.list[index]),
        ),
      ),
    );
  }

  Future<void> _onRefresh(FavouriteTopicListNotifier notifier) async {
    try {
      await notifier.refresh();
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error((err as dynamic).message ?? err.toString());
    }
  }

  Future<void> _onLoading(FavouriteTopicListNotifier notifier) async {
    try {
      final state = await notifier.loadMore();
      if (!mounted) return;
      if (state.page + 1 < state.maxPage) {
        _refreshController.finishLoad();
      } else {
        _refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (_) {
      if (!mounted) return;
      _refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  void _showDeleteDialog(FavouriteTopicListNotifier notifier, Topic topic) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该收藏"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  notifier.delete(topic).then((message) {
                    AppToast.success(message ?? "");
                  });
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
