import 'package:mobx/mobx.dart';

part 'input_deletion.g.dart';

class InputDeletion = _InputDeletion with _$InputDeletion;

abstract class _InputDeletion with Store {
  @observable
  bool visible = false;

  @action
  void setVisible(bool val) {
    visible = val;
  }
}
