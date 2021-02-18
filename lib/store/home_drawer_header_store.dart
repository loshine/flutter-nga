import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:mobx/mobx.dart';

part 'home_drawer_header_store.g.dart';

class HomeDrawerHeaderStore = _HomeDrawerHeaderStore with _$HomeDrawerHeaderStore;

abstract class _HomeDrawerHeaderStore with Store {
  @observable
  UserInfo userInfo;

  @action
  Future refresh() async {
    try {
      CacheUser user = await Data().userRepository.getDefaultUser();
      if (user != null) {
        userInfo = await Data().userRepository.getUserInfoByUid(user.uid);
      }
    } catch (err) {
      rethrow;
    }
  }
}
