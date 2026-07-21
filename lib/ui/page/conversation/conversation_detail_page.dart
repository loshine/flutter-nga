import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/conversation_detail_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'message_item_widget.dart';

class ConversationDetailPage extends ConsumerStatefulWidget {
  final int? mid;

  const ConversationDetailPage({super.key, this.mid});

  @override
  ConsumerState<ConversationDetailPage> createState() =>
      _ConversationDetailState();
}

class _ConversationDetailState extends ConsumerState<ConversationDetailPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(conversationDetailProvider.notifier));
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
    final state = ref.watch(conversationDetailProvider);
    final notifier = ref.read(conversationDetailProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('消息详情'),
      ),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        onLoad: state.enablePullUp ? () => _onLoading(notifier) : null,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              MessageItemWidget(message: state.list[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '回复',
        onPressed: () => Routes.navigateTo(
          context,
          "${Routes.SEND_MESSAGE}?mid=${widget.mid}",
        ),
        child: Icon(Icons.reply),
      ),
    );
  }

  Future<void> _onRefresh(ConversationDetailNotifier notifier) async {
    try {
      await notifier.refresh(widget.mid);
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error(err.toString());
    }
  }

  Future<void> _onLoading(ConversationDetailNotifier notifier) async {
    try {
      final state = await notifier.loadMore(widget.mid);
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
