/// 表情实体类
class Emoticon {
  const Emoticon({this.content, this.url})
      : assert(content != null),
        assert(url != null);
  final String content;
  final String url;
}

/// 表情包实体类
class EmoticonGroup {
  const EmoticonGroup(this.name, this.expressionList)
      : assert(name != null),
        assert(expressionList != null);

  final String name;
  final List<Emoticon> expressionList;
}
