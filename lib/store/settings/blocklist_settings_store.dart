import 'package:flutter_nga/data/data.dart';
import 'package:mmkv/mmkv.dart';
import 'package:mobx/mobx.dart';

part 'blocklist_settings_store.g.dart';

class BlocklistSettingsStore = _BlocklistSettingsStore
    with _$BlocklistSettingsStore;

enum BlockMode { COLLAPSE, PAINT, ALPHA, DELETE_LINE, GONE }

extension BlockModeExtention on BlockMode {
  // double get size {
  //   switch (this) {
  //     case CustomLineHeight.NORMAL:
  //       return 1.2;
  //     case CustomLineHeight.LARGE:
  //       return 1.6;
  //     case CustomLineHeight.XLARGE:
  //       return 1.8;
  //     case CustomLineHeight.XXLARGE:
  //       return 2.0;
  //     case CustomLineHeight.MEDIUM:
  //     default:
  //       return 1.4;
  //   }
  // }

  String get name {
    switch (this) {
      case BlockMode.COLLAPSE:
        return "折叠";
      case BlockMode.PAINT:
        return "涂抹";
      case BlockMode.ALPHA:
        return "淡化";
      case BlockMode.DELETE_LINE:
        return "删除线";
      case BlockMode.GONE:
      default:
        return "隐藏";
    }
  }
}

abstract class _BlocklistSettingsStore with Store {
  final settings = MMKV("blocklist");

  @observable
  var clientEnabled = false;

  @observable
  var blockUserList = [];

  @observable
  var blockWordList = [];

  @action
  void init() {
    clientEnabled = settings.decodeBool("clientEnabled", defaultValue: false);
  }

  @action
  void setClientEnabled(bool enabled) {
    clientEnabled = enabled;
    settings.encodeBool("clientEnabled", clientEnabled);
  }

  @action
  Future<void> load() async {
    try {
      final blockInfo = await Data().userRepository.getBlockInfo();
      blockUserList = blockInfo.blockUserList;
      blockWordList = blockInfo.blockWordList;
    } catch (err) {
      rethrow;
    }
  }
}
