import 'package:bloc/bloc.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_event.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_state.dart';

class TopicListBloc extends Bloc<TopicListEvent, TopicListState> {
  @override
  TopicListState get initialState => TopicListState.initial();

  @override
  Stream<TopicListState> mapEventToState(
      TopicListState currentState, TopicListEvent event) {
    return null;
  }
}
