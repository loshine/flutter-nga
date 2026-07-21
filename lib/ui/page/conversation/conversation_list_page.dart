import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'conversation_item_widget.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<ConversationListPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(conversationListProvider.notifier));
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
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('短消息')),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        onLoad: state.enablePullUp ? () => _onLoading(notifier) : null,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              ConversationItemWidget(conversation: state.list[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () =>
            Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  Future<void> _onRefresh(ConversationListNotifier notifier) async {
    try {
      await notifier.refresh();
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error(err.toString());
    }
  }

  Future<void> _onLoading(ConversationListNotifier notifier) async {
    try {
      final state = await notifier.loadMore();
      if (!mounted) return;
      if (state.enablePullUp) {
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
