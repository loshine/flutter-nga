/// 表情实体类
class Emoticon {
  const Emoticon({required this.content, required this.url});

  final String content;
  final String url;
}

/// 表情包实体类
class EmoticonGroup {
  const EmoticonGroup(this.name, this.expressionList);

  final String name;
  final List<Emoticon> expressionList;
}
