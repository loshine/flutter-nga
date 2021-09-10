import 'package:mmkv/mmkv.dart';
import 'package:mobx/mobx.dart';

part 'interface_settings_store.g.dart';

class InterfaceSettingsStore = _InterfaceSettingsStore
    with _$InterfaceSettingsStore;

abstract class _InterfaceSettingsStore with Store {
  final settings = MMKV("ui");

  @observable
  var contentSizeMultiple = 1.0;

  @observable
  var titleSizeMultiple = 1.0;

  @action
  void init() {
    contentSizeMultiple =
        settings.decodeDouble("contentSizeMultiple", defaultValue: 1.0);
    titleSizeMultiple =
        settings.decodeDouble("titleSizeMultiple", defaultValue: 1.0);
  }

  @action
  void setContentSizeMultiple(double multiple) {
    contentSizeMultiple = multiple;
    settings.encodeDouble("contentSizeMultiple", contentSizeMultiple);
  }

  @action
  void setTitleSizeMultiple(double multiple) {
    titleSizeMultiple = multiple;
    settings.encodeDouble("titleSizeMultiple", titleSizeMultiple);
  }
}
