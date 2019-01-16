class TopicTag {
  const TopicTag({this.id, this.content})
      : assert(id != null),
        assert(content != null);

  final int id;
  final String content;
}
