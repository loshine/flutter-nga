import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  @observable
  var index = 0;

  @action
  void setIndex(int index) {
    this.index = index;
  }
}
