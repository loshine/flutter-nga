import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:mobx/mobx.dart';

part 'conversation_detail_store.g.dart';

class ConversationDetailStore = _ConversationDetailStore
    with _$ConversationDetailStore;

abstract class _ConversationDetailStore with Store {
  @observable
  ConversationDetailStoreData state = ConversationDetailStoreData.initial();

  @action
  Future<ConversationDetailStoreData> refresh(int mid) async {
    try {
      MessageListData data =
          await Data().messageRepository.getMessageList(mid, 1);
      state = ConversationDetailStoreData(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.messageList.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<ConversationDetailStoreData> loadMore(int mid) async {
    try {
      MessageListData data =
          await Data().messageRepository.getMessageList(mid, state.page + 1);
      state = ConversationDetailStoreData(
        page: state.page + 1,
        enablePullUp: data.hasNext,
        list: state.list..addAll(data.messageList),
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

  const ConversationDetailStoreData({
    this.page,
    this.enablePullUp,
    this.list,
  });

  factory ConversationDetailStoreData.initial() => ConversationDetailStoreData(
        page: 1,
        enablePullUp: false,
        list: [],
      );
}
