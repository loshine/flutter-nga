import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:mobx/mobx.dart';

part 'search_store.g.dart';

class SearchStore = _SearchStore with _$SearchStore;

abstract class _SearchStore with Store {
  bool isLoadingShow = false;

  @action
  Future<UserInfo> searchByUsername(String username) async {
    isLoadingShow = true;
    try {
      UserInfo userInfo =
          await Data().userRepository.getUserInfoByName(username);
      isLoadingShow = false;
      return userInfo;
    } catch (err) {
      isLoadingShow = false;
      rethrow;
    }
  }
}
