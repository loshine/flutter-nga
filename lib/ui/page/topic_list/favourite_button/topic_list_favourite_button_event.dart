abstract class TopicListFavouriteButtonEvent {
  factory TopicListFavouriteButtonEvent.favouriteChanged(
          bool isFavourite, int fid, String name) =>
      TopicListFavouriteButtonChangedEvent(
          isFavourite: isFavourite, fid: fid, name: name);

  factory TopicListFavouriteButtonEvent.load(int fid, String name) =>
      TopicListFavouriteButtonLoadEvent(fid: fid, name: name);
}

class TopicListFavouriteButtonChangedEvent
    implements TopicListFavouriteButtonEvent {
  const TopicListFavouriteButtonChangedEvent({
    this.isFavourite,
    this.fid,
    this.name,
  });

  final bool isFavourite;
  final int fid;
  final String name;
}

class TopicListFavouriteButtonLoadEvent
    implements TopicListFavouriteButtonEvent {
  const TopicListFavouriteButtonLoadEvent({
    this.fid,
    this.name,
  });

  final int fid;
  final String name;
}
