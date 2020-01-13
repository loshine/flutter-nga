import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:mobx/mobx.dart';

part 'account_list.g.dart';

class AccountList = _AccountList with _$AccountList;

abstract class _AccountList with Store {
  @observable
  List<User> list = [];

  @action
  Future refresh() async {
    List<User> accountList = await Data().userRepository.getAllLoginUser();
    this.list
      ..clear()
      ..addAll(accountList);
  }

  @action
  Future<int> quitAll() {
    return Data().userRepository.quitAllLoginUser();
  }
}
