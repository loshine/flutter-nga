import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/user/user_topics_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserTopicsPage extends ConsumerStatefulWidget {
  final int uid;
  final String username;

  const UserTopicsPage({
    super.key,
    required this.uid,
    required this.username,
  });

  @override
  ConsumerState<UserTopicsPage> createState() => _UserTopicsPageState();
}

class _UserTopicsPageState extends ConsumerState<UserTopicsPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(userTopicsProvider.notifier));
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
    final state = ref.watch(userTopicsProvider);
    final notifier = ref.read(userTopicsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}发布的主题")),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        onLoad: state.enablePullUp ? () => _onLoading(notifier) : null,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              TopicListItemWidget(topic: state.list[index]),
        ),
      ),
    );
  }

  Future<void> _onRefresh(UserTopicsNotifier notifier) async {
    try {
      await notifier.refresh(widget.uid);
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error((err as dynamic).message ?? err.toString());
    }
  }

  Future<void> _onLoading(UserTopicsNotifier notifier) async {
    try {
      final state = await notifier.loadMore(widget.uid);
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
}
