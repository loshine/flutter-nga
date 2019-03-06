class TopicListFavouriteButtonState {
  const TopicListFavouriteButtonState(this.isFavourite);

  final bool isFavourite;

  factory TopicListFavouriteButtonState.initial() =>
      TopicListFavouriteButtonState(false);
}
