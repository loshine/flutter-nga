import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:mobx/mobx.dart';

part 'account_list_store.g.dart';

class AccountListStore = _AccountListStore with _$AccountListStore;

abstract class _AccountListStore with Store {
  @observable
  List<CacheUser> list = [];

  @action
  Future refresh() async {
    List<CacheUser> accountList = await Data().userRepository.getAllLoginUser();
    list = accountList;
  }

  @action
  Future<int> quitAll() {
    return Data().userRepository.quitAllLoginUser();
  }
}
