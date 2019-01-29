class ContentParser {
  static String parse(String content) {
    // TODO: [] 标签转为 html 标签
    return content
        .replaceAllMapped(
            RegExp("\\[img]([\\s\\S]*?)\\[/img]"), _imgReplaceFunc)
        .replaceAll("[quote]", "<blockquote>")
        .replaceAll("[/quote]", "</blockquote>");
  }
}

String _imgReplaceFunc(Match match) {
  final imgUrl = match.group(1).startsWith("./mon_")
      ? "https://img.nga.178.com/attachments${match.group(1).substring(1)}"
      : match.group(1);
  return "<a href='$imgUrl'><img src='$imgUrl' ></a>";
}
