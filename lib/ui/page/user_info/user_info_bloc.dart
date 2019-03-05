import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/user_info/user_info.dart';
import 'package:flutter_nga/ui/page/user_info/user_info_state.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserInfoBloc extends Bloc<GetUserInfoEvent, UserInfoState> {
  void onLoad(String username) {
    dispatch(GetUserInfoEvent(username));
  }

  @override
  UserInfoState get initialState => UserInfoState.initial();

  @override
  Stream<UserInfoState> mapEventToState(
      UserInfoState currentState, GetUserInfoEvent event) async* {
    try {
      final userInfo = await Data().userRepository.getUserInfo(event.username);
      final moderatorForumsMap = <int, String>{};
      if (userInfo != null &&
          userInfo.adminForums != null &&
          userInfo.adminForums.isNotEmpty) {
        userInfo.adminForums.entries.forEach((entry) {
          moderatorForumsMap[int.parse(entry.key)] =
              "${CodeUtils.unescapeHtml(entry.value)}";
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
            "${CodeUtils.unescapeHtml(userInfo.userForum['1'])}";
      }
      yield UserInfoState(
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
              '${CodeUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(userInfo.registerDate * 1000))}'
        },
        signature: CodeUtils.isStringEmpty(userInfo.sign)
            ? "暂无签名"
            : "${NgaContentParser.parse(userInfo.sign)}",
        moderatorForums: moderatorForumsMap,
        reputationMap: reputationMap,
        personalForum: personalForumMap,
      );
    } on DioError catch (err) {
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    } on Error catch (err) {
      Fluttertoast.showToast(
        msg: err.toString(),
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
