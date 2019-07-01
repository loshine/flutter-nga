import 'package:bloc/bloc.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/page/favourite_forum_group/favourite_forum_group.dart';
import 'package:flutter_nga/ui/page/topic_list/favourite_button/topic_list_favourite_button_event.dart';
import 'package:flutter_nga/ui/page/topic_list/favourite_button/topic_list_favourite_button_state.dart';

class TopicListFavouriteButtonBloc
    extends Bloc<TopicListFavouriteButtonEvent, TopicListFavouriteButtonState> {
  @override
  TopicListFavouriteButtonState get initialState =>
      TopicListFavouriteButtonState.initial();

  onFavouriteChanged(bool isFavourite, int fid, String name) async {
    dispatch(
        TopicListFavouriteButtonEvent.favouriteChanged(isFavourite, fid, name));
  }

  void onLoadFavourite(int fid, String name) {
    dispatch(TopicListFavouriteButtonEvent.load(fid, name));
  }

  @override
  Stream<TopicListFavouriteButtonState> mapEventToState(
      TopicListFavouriteButtonEvent event) async* {
    if (event is TopicListFavouriteButtonChangedEvent) {
      if (!event.isFavourite) {
        await Data()
            .forumRepository
            .deleteFavourite(Forum(event.fid, event.name));
      } else {
        await Data()
            .forumRepository
            .saveFavourite(Forum(event.fid, event.name));
      }
      FavouriteForumGroupBloc().onChanged();
      yield TopicListFavouriteButtonState(event.isFavourite);
    } else if (event is TopicListFavouriteButtonLoadEvent) {
      final isFavourite = await Data()
          .forumRepository
          .isFavourite(Forum(event.fid, event.name));
      yield TopicListFavouriteButtonState(isFavourite);
    }
  }
}
