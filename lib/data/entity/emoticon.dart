/// 表情实体类
class Emoticon {
  const Emoticon({
    required this.content,
    required this.url,
    required this.height,
    required this.descent,
  });

  final String content;
  final String url;

  /// 图片原始高度（逻辑像素）。网页版不限制表情尺寸，按原图显示，这里与之对齐。
  final double height;

  /// 图片底边低于文字基线的距离，对应网页的 CSS `vertical-align: -descent`。
  final double descent;
}

/// 表情包实体类
class EmoticonGroup {
  const EmoticonGroup(this.name, this.expressionList);

  final String name;
  final List<Emoticon> expressionList;
}
