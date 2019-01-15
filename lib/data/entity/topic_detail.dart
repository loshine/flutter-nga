class TopicDetailData {
  final Map<String, Reply> replyList;
  final Map<String, User> userList;

  final Map<String, Group> groupList;
  final Map<String, Medal> medalList;
  final Map<String, Reputation> reputationList;

  final dynamic global;
  final int rows;
  final int currentRows;
  final int rRows;

  const TopicDetailData({
    this.global,
    this.userList,
    this.replyList,
    this.groupList,
    this.medalList,
    this.reputationList,
    this.rows,
    this.currentRows,
    this.rRows,
  });

  factory TopicDetailData.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> userMap = map["__U"];
    Map<String, dynamic> replyMap = map["__R"];
    Map<String, User> tempUserMap = {};
    Map<String, Group> tempGroupMap = {};
    Map<String, Medal> tempMedalMap = {};
    Map<String, Reputation> tempReputationMap = {};
    for (MapEntry<String, dynamic> entry in userMap.entries) {
      int key = int.tryParse(entry.key);
      if (key == null) {
        // __GROUPS 用户等级
        if ("__GROUPS" == entry.key) {
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempGroupMap[m.key] = Group.fromJson(m.value);
          }
        } else if ("__MEDALS" == entry.key) {
          // __MEDALS 奖牌
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempMedalMap[m.key] = Medal.fromJson(m.value);
          }
        } else if ("__REPUTATIONS" == entry.key) {
          // __REPUTATIONS 威望
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempReputationMap[m.key] = Reputation.fromJson(m.value);
          }
        }
      } else {
        tempUserMap[entry.key] = User.fromJson(entry.value);
      }
    }
    Map<String, Reply> tempReplyMap = {};
    for (MapEntry<String, dynamic> entry in replyMap.entries) {
      tempReplyMap[entry.key] = Reply.fromJson(entry.value);
    }
    return TopicDetailData(
      global: map["__GLOBAL"],
      userList: tempUserMap,
      replyList: tempReplyMap,
      groupList: tempGroupMap,
      medalList: tempMedalMap,
      reputationList: tempReputationMap,
      currentRows: map["__R__ROWS"],
      rRows: map["__R__ROWS_PAGE"],
      rows: map["__ROWS"],
    );
  }
}

class User {
  final int uid;
  final String username;
  final int credit;
  final String medal;
  final String reputation;
  final int groupId;
  final int memberId;
  final String avatar; // 可能是 String，也可能是 map
  final List<String> avatarList; // 当 avatar 是 map 的时候用来替代
  final int yz;
  final String site;
  final String honor;
  final int regDate;
  final String muteTime;
  final int postNum;
  final int rvrc;
  final int money;
  final int thisVisit;
  final String signature;
  final String nickname;
  final int bitData;

  const User(
      {this.uid,
      this.username,
      this.credit,
      this.medal,
      this.reputation,
      this.groupId,
      this.memberId,
      this.avatar,
      this.avatarList,
      this.yz,
      this.site,
      this.honor,
      this.regDate,
      this.muteTime,
      this.postNum,
      this.rvrc,
      this.money,
      this.thisVisit,
      this.signature,
      this.nickname,
      this.bitData});

  factory User.fromJson(Map<String, dynamic> map) {
    dynamic avatar = map["avatar"];
    List<String> avatarList = [];
    if (avatar != null) {
      if (avatar is String) {
        avatarList.add(avatar);
      } else if (avatar is Map) {
        final size = avatar["l"];
        if (size != null && size is int) {
          for (int i = 0; i < size; i++) {
            if (avatar["$i"] is String) {
              avatarList.add(avatar["$i"]);
            } else if (avatar["$i"] is Map) {
              avatarList.add(avatar["$i"][0]);
            }
          }
        }
        avatar = avatarList[0];
      }
    }
    return User(
      uid: map["uid"],
      username: map["username"].toString(), // 可能是int
      credit: map["credit"],
      medal: map["medal"].toString(),
      reputation: map["reputation"].toString(),
      groupId: map["groupid"],
      memberId: map["memberid"],
      avatar: avatar,
      avatarList: avatarList,
      yz: map["yz"],
      site: map["site"],
      honor: map["honor"],
      regDate: map["regdate"],
      muteTime: map["mute_time"],
      postNum: map["postnum"],
      rvrc: map["rvrc"],
      money: map["money"],
      thisVisit: map["thisvisit"],
      signature: map["signature"].toString(), // 可能是int
      nickname: map["nickname"],
      bitData: map["bit_data"],
    );
  }
}

class Reply {
  final String content;
  final String alterInfo;
  final int tid;
  final int score;
  final int score2;
  final String postDate;
  final int authorId;
  final String subject;
  final int type;
  final int fid;
  final int pid;
  final int recommend;
  final int lou;
  final int contentLength;
  final int postDateTimestamp;

  const Reply(
      {this.content,
      this.alterInfo,
      this.tid,
      this.score,
      this.score2,
      this.postDate,
      this.authorId,
      this.subject,
      this.type,
      this.fid,
      this.pid,
      this.recommend,
      this.lou,
      this.contentLength,
      this.postDateTimestamp});

  factory Reply.fromJson(Map<String, dynamic> map) {
    return Reply(
      content: map["content"],
      alterInfo: map["alterinfo"],
      tid: map["tid"],
      score: map["score"],
      score2: map["score_2"],
      postDate: map["postdate"],
      authorId: map["authorid"],
      subject: map["subject"],
      type: map["type"],
      fid: map["fid"],
      pid: map["pid"],
      recommend: map["recommend"],
      lou: map["lou"],
// 实际上无用属性，还可能是字符串，干脆不要了
//      contentLength: int.tryParse(map["content_length"]) ?? 0,
      postDateTimestamp: map["postdatetimestamp"],
    );
  }
}

class Group {
  final int id;
  final String name;

  const Group(this.id, this.name);

  factory Group.fromJson(Map<String, dynamic> map) {
    return Group(map["2"], map["0"]);
  }
}

class Medal {
  final int id;
  final String name;
  final String description;
  final String image;

  const Medal(this.id, this.name, this.description, this.image);

  factory Medal.fromJson(Map<String, dynamic> map) {
    return Medal(map["3"], map["1"], map["2"], map["0"]);
  }
}

class Reputation {
  const Reputation();

  factory Reputation.fromJson(Map<String, dynamic> map) {
    return Reputation();
  }
}
