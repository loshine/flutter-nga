import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:mobx/mobx.dart';

part 'conversation_list_store.g.dart';

class ConversationListStore = _ConversationListStore
    with _$ConversationListStore;

abstract class _ConversationListStore with Store {
  @observable
  ConversationListStoreData state = ConversationListStoreData.initial();

  @action
  Future<ConversationListStoreData> refresh() async {
    try {
      ConversationListData data =
          await Data().messageRepository.getConversationList(1);
      state = ConversationListStoreData(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.conversationList.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<ConversationListStoreData> loadMore() async {
    try {
      ConversationListData data =
          await Data().messageRepository.getConversationList(state.page + 1);
      state = ConversationListStoreData(
        page: state.page + 1,
        enablePullUp: data.hasNext,
        list: state.list..addAll(data.conversationList),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class ConversationListStoreData {
  final int page;
  final bool enablePullUp;
  final List<Conversation> list;

  const ConversationListStoreData({
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory ConversationListStoreData.initial() => ConversationListStoreData(
        page: 1,
        enablePullUp: false,
        list: [],
      );
}
