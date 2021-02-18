import 'package:mobx/mobx.dart';

part 'input_deletion_status_store.g.dart';

class InputDeletionStatusStore = _InputDeletionStatusStore
    with _$InputDeletionStatusStore;

abstract class _InputDeletionStatusStore with Store {
  @observable
  bool visible = false;

  @action
  void setVisible(bool val) {
    visible = val;
  }
}
