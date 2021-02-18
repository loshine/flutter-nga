import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart' as User;
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:mobx/mobx.dart';

part 'user_info_store.g.dart';

class UserInfoStore = _UserInfoStore with _$UserInfoStore;

abstract class _UserInfoStore with Store {
  @observable
  UserInfoStoreData state = UserInfoStoreData.initial();

  @action
  Future<UserInfoStoreData> loadByName(String username) async {
    try {
      final userInfo = await Data().userRepository.getUserInfoByName(username);
      state = _buildStateByInfo(userInfo);
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<UserInfoStoreData> loadByUid(String uid) async {
    try {
      final userInfo = await Data().userRepository.getUserInfoByUid(uid);
      state = _buildStateByInfo(userInfo);
      return state;
    } catch (err) {
      rethrow;
    }
  }

  UserInfoStoreData _buildStateByInfo(User.UserInfo userInfo) {
    final moderatorForumsMap = <int, String>{};
    if (userInfo != null &&
        userInfo.adminForums != null &&
        userInfo.adminForums.isNotEmpty) {
      userInfo.adminForums.entries.forEach((entry) {
        moderatorForumsMap[int.parse(entry.key)] =
            "${codeUtils.unescapeHtml(entry.value)}";
      });
    }
    final reputationMap = <String, String>{};
    reputationMap['威望'] = "${userInfo == null ? 0 : userInfo.fame / 10}";
    if (userInfo != null &&
        userInfo.reputation != null &&
        userInfo.reputation.isNotEmpty) {
      userInfo.reputation.forEach((reputation) {
        reputationMap[reputation.name] = "${reputation.value}";
      });
    }
    final personalForumMap = <int, String>{};
    if (userInfo != null && userInfo.userForum != null) {
      personalForumMap[userInfo.userForum['0']] =
          "${codeUtils.unescapeHtml(userInfo.userForum['1'])}";
    }
    return UserInfoStoreData(
      uid: userInfo.uid,
      username: userInfo.username,
      avatar: userInfo.avatar,
      basicInfoMap: {
        '用户ID': '${userInfo.uid}',
        '用户名': '${userInfo.username}',
        '用户组': '${userInfo.group}(${userInfo.groupId})',
        '财富':
            '${userInfo.money ~/ 10000}金 ${(userInfo.money % 10000) ~/ 100}银 ${userInfo.money % 100}铜',
        '注册日期':
            '${codeUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(userInfo.registerDate * 1000))}'
      },
      signature: codeUtils.isStringEmpty(userInfo.sign)
          ? "暂无签名"
          : "${NgaContentParser.parse(userInfo.sign)}",
      moderatorForums: moderatorForumsMap,
      reputationMap: reputationMap,
      personalForum: personalForumMap,
    );
  }
}

class UserInfoStoreData {
  final int uid;
  final String username;
  final String avatar;
  final Map<String, String> basicInfoMap;
  final String signature;
  final Map<int, String> moderatorForums; // 管理版面
  final Map<String, String> reputationMap; // 声望
  final Map<int, String> personalForum; // 个人版面

  const UserInfoStoreData({
    this.uid,
    this.username,
    this.avatar,
    this.basicInfoMap,
    this.signature,
    this.moderatorForums,
    this.reputationMap,
    this.personalForum,
  });

  factory UserInfoStoreData.initial() => UserInfoStoreData(
        uid: 0,
        username: "",
        avatar: "",
        basicInfoMap: {
          '用户ID': 'N/A',
          '用户名': 'N/A',
          '用户组': 'N/A',
          '财富': 'N/A',
          '注册日期': 'N/A'
        },
        signature: "N/A",
        moderatorForums: {},
        reputationMap: {
          '威望': '0.0',
        },
        personalForum: {},
      );
}
