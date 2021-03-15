import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:mobx/mobx.dart';

part 'conversation_detail_store.g.dart';

class ConversationDetailStore = _ConversationDetailStore
    with _$ConversationDetailStore;

abstract class _ConversationDetailStore with Store {
  @observable
  ConversationDetailStoreData state = ConversationDetailStoreData.initial();

  @action
  Future<ConversationDetailStoreData> refresh(
      BuildContext context, int? mid) async {
    try {
      MessageListData data =
          await Data().messageRepository.getMessageList(mid, 1);
      final isDark = await Palette.isDark(context);
      state = ConversationDetailStoreData(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.messageList.toList(),
        isDark: isDark,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<ConversationDetailStoreData> loadMore(
      BuildContext context, int? mid) async {
    try {
      MessageListData data =
          await Data().messageRepository.getMessageList(mid, state.page + 1);
      final isDark = await Palette.isDark(context);
      state = ConversationDetailStoreData(
        page: state.page + 1,
        enablePullUp: data.hasNext,
        list: state.list..addAll(data.messageList),
        isDark: isDark,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class ConversationDetailStoreData {
  final int page;
  final bool enablePullUp;
  final List<Message> list;
  final bool isDark;

  const ConversationDetailStoreData({
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.isDark = false,
  });

  factory ConversationDetailStoreData.initial() => ConversationDetailStoreData(
        page: 1,
        enablePullUp: false,
        list: [],
        isDark: false,
      );
}
