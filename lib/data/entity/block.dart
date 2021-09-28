class BlockInfoData {
  final List<String> blockUserList;
  final List<String> blockWordList;

  BlockInfoData(this.blockUserList, this.blockWordList);

  factory BlockInfoData.fromJson(Map map) {
    String data = map["0"];
    final userList = <String>[];
    final wordList = <String>[];
    // 1 代表有屏蔽信息
    if (data.startsWith("1\n")) {
      // 第一个 \n 后是屏蔽词
      final wordsAndUsers = data.substring("1\n".length);
      // 第二个 \n 后是屏蔽用户
      final secondGapIndex = wordsAndUsers.indexOf("\n");
      // 如果没有第二个 \n
      if (secondGapIndex < 0) {
        wordList.addAll(wordsAndUsers.split(" "));
      } else {
        final words = wordsAndUsers.substring(0, secondGapIndex);
        final users = wordsAndUsers.substring(secondGapIndex + 1);
        wordList.addAll(words.split(" "));
        userList.addAll(users.split(" "));
      }
    }
    return BlockInfoData(userList, wordList);
  }

  String toData() {
    final data = StringBuffer();
    if (blockWordList.isNotEmpty || blockUserList.isNotEmpty) {
      data.write("1\n");
      if (blockWordList.isNotEmpty) {
        data.write(blockWordList.reduce((value, e) => "$value $e"));
      }
      if (blockUserList.isNotEmpty) {
        data.write("\n");
        data.write(blockUserList.reduce((value, e) => "$value $e"));
      }
    }
    return data.toString();
  }
}
