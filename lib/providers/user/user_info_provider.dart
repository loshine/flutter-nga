import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart' as user;
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfoState {
  final int? uid;
  final String? username;
  final String? avatar;
  final Map<String, String>? basicInfoMap;
  final String? signature;
  final Map<int, String>? moderatorForums;
  final Map<String?, String>? reputationMap;
  final Map<int?, String>? personalForum;
  final bool isLoading;

  const UserInfoState({
    this.uid,
    this.username,
    this.avatar,
    this.basicInfoMap,
    this.signature,
    this.moderatorForums,
    this.reputationMap,
    this.personalForum,
    this.isLoading = false,
  });

  String get realAvatarUrl {
    if (avatar == null) {
      return "";
    } else if (avatar!.startsWith("http://")) {
      return avatar!.replaceAll("http://", "https://");
    } else {
      return avatar!;
    }
  }

  factory UserInfoState.initial() => UserInfoState(
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
        reputationMap: {'威望': '0.0'},
        personalForum: {},
      );
}

class UserInfoNotifier extends Notifier<UserInfoState> {
  @override
  UserInfoState build() => UserInfoState.initial();

  Future<UserInfoState> loadByName(String? username) async {
    state = UserInfoState.initial().copyWith(isLoading: true);
    try {
      final userInfo = await Data().userRepository.getUserInfoByName(username);
      state = _buildStateByInfo(userInfo);
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<UserInfoState> loadByUid(String? uid) async {
    state = UserInfoState.initial().copyWith(isLoading: true);
    try {
      final userInfo = await Data().userRepository.getUserInfoByUid(uid);
      state = _buildStateByInfo(userInfo);
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  UserInfoState _buildStateByInfo(user.UserInfo userInfo) {
    final moderatorForumsMap = <int, String>{};
    if (userInfo.adminForums != null && userInfo.adminForums!.isNotEmpty) {
      userInfo.adminForums!.entries.forEach((entry) {
        moderatorForumsMap[int.parse(entry.key)] =
            "${code_utils.unescapeHtml(entry.value)}";
      });
    }
    final reputationMap = <String?, String>{};
    reputationMap['威望'] = "${userInfo.fame! / 10}";
    if (userInfo.reputation != null && userInfo.reputation!.isNotEmpty) {
      userInfo.reputation!.forEach((reputation) {
        reputationMap[reputation.name] = "${reputation.value}";
      });
    }
    final personalForumMap = <int?, String>{};
    if (userInfo.userForum != null) {
      personalForumMap[userInfo.userForum!['0']] =
          "${code_utils.unescapeHtml(userInfo.userForum!['1'])}";
    }
    return UserInfoState(
      uid: userInfo.uid,
      username: userInfo.username,
      avatar: userInfo.avatar,
      basicInfoMap: {
        '用户ID': '${userInfo.uid}',
        '用户名': '${userInfo.username}',
        '用户组': '${userInfo.group}(${userInfo.groupId})',
        '财富':
            '${userInfo.money! ~/ 10000}金 ${(userInfo.money! % 10000) ~/ 100}银 ${userInfo.money! % 100}铜',
        '注册日期':
            '${code_utils.formatDate(DateTime.fromMillisecondsSinceEpoch(userInfo.registerDate! * 1000))}'
      },
      signature: code_utils.isStringEmpty(userInfo.sign)
          ? "暂无签名"
          : "${NgaContentParser.parse(userInfo.sign)}",
      moderatorForums: moderatorForumsMap,
      reputationMap: reputationMap,
      personalForum: personalForumMap,
      isLoading: false,
    );
  }
}

extension UserInfoStateCopyWith on UserInfoState {
  UserInfoState copyWith({bool? isLoading}) {
    return UserInfoState(
      uid: uid,
      username: username,
      avatar: avatar,
      basicInfoMap: basicInfoMap,
      signature: signature,
      moderatorForums: moderatorForums,
      reputationMap: reputationMap,
      personalForum: personalForum,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final userInfoProvider =
    NotifierProvider<UserInfoNotifier, UserInfoState>(UserInfoNotifier.new);
