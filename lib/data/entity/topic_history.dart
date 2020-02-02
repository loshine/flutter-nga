class TopicHistory {
  TopicHistory({this.tid, this.fid, this.subject, this.time})
      : assert(tid != null),
        assert(fid != null),
        assert(subject != null);

  int id;
  final int tid;
  final int fid;
  final String subject;
  final int time;

  Map<String, dynamic>  toJson() {
    return {'tid': tid, 'fid': fid, 'subject': subject, 'time': time};
  }

  factory TopicHistory.fromJson(Map map) {
    return TopicHistory(
      tid: map['tid'],
      fid: map['fid'],
      subject: map['subject'],
      time: map['time'],
    );
  }
}
