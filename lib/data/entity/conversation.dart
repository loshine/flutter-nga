class Conversation {
  final int mid;
  final int lastModify;
  final int bit;
  final String subject;
  final int from;
  final int time;
  final int lastFrom;
  final int posts;
  final int sbit;
  final String fromUsername;
  final String lastFromUsername;

  String get realFromUsername => from == 0 ? '#SYSTEM#' : fromUsername;

  String get users =>
      "$realFromUsername${lastFromUsername != '' ? ", $lastFromUsername" : ''}";

  bool get isMultiUser => bit & 1 == 1;

  bool get isUnread => bit & 2 == 2;

  Conversation(
    this.mid,
    this.lastModify,
    this.bit,
    this.subject,
    this.from,
    this.time,
    this.lastFrom,
    this.posts,
    this.sbit,
    this.fromUsername,
    this.lastFromUsername,
  );

// final String allUser;

  factory Conversation.fromJson(Map map) {
    return Conversation(
        map['mid'],
        map['last_modify'],
        map['bit'],
        map['subject'],
        map['from'],
        map['time'],
        map['last_from'],
        map['posts'],
        map['sbit'],
        map['from_username'],
        map['last_from_username']);
  }
}

class ConversationListData {
  final int nextPage;
  final int currentPage;
  final int rowsPerPage;
  final List<Conversation> conversationList;

  bool get hasNext => nextPage == 1;

  ConversationListData(
    this.nextPage,
    this.currentPage,
    this.rowsPerPage,
    this.conversationList,
  );

  factory ConversationListData.fromJson(Map map) {
    Map<String, Conversation> tempMap = {};
    for (MapEntry<String, dynamic> entry in map.entries) {
      if (entry.key != 'nextPage' &&
          entry.key != 'currentPage' &&
          entry.key != 'rowsPerPage') {
        tempMap[entry.key] = Conversation.fromJson(entry.value);
      }
    }
    return ConversationListData(
      map['nextPage'],
      map['currentPage'],
      map['rowsPerPage'],
      tempMap.values.toList(),
    );
  }
}
