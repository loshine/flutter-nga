import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/block.dart';
import 'package:mmkv/mmkv.dart';
import 'package:mobx/mobx.dart';

part 'blocklist_settings_store.g.dart';

class BlocklistSettingsStore = _BlocklistSettingsStore
    with _$BlocklistSettingsStore;

enum BlockMode { COLLAPSE, PAINT, ALPHA, DELETE_LINE, GONE }

extension BlockModeExtention on BlockMode {
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
        return "隐藏";
    }
  }
}

abstract class _BlocklistSettingsStore with Store {
  final settings = MMKV("blocklist");

  @observable
  var clientBlockEnabled = false;

  @observable
  var listBlockEnabled = true;

  @observable
  var detailsBlockEnabled = true;

  @observable
  var blockMode = BlockMode.COLLAPSE;

  @observable
  var blockUserList = <String>[];

  @observable
  var blockWordList = <String>[];

  @action
  void init() {
    clientBlockEnabled =
        settings.decodeBool("clientBlockEnabled", defaultValue: false);
    listBlockEnabled =
        settings.decodeBool("listBlockEnabled", defaultValue: true);
    detailsBlockEnabled =
        settings.decodeBool("detailsBlockEnabled", defaultValue: true);
    blockMode = getBlockMode();
  }

  @action
  loopSyncBlockList() {
    Future.delayed(Duration(), () async {
      debugPrint('定时任务');
      if (await Data().userRepository.getDefaultUser() != null) {
        await load();
      }
    }).whenComplete(() {
      Future.delayed(Duration(minutes: 5), () => loopSyncBlockList());
    }).catchError((err) {
      debugPrint(err.toString());
    });
  }

  @action
  void setClientBlockEnabled(bool enabled) {
    clientBlockEnabled = enabled;
    settings.encodeBool("clientBlockEnabled", clientBlockEnabled);
  }

  @action
  void setListBlockEnabled(bool enabled) {
    listBlockEnabled = enabled;
    settings.encodeBool("listBlockEnabled", listBlockEnabled);
  }

  @action
  void setDetailsBlockEnabled(bool enabled) {
    detailsBlockEnabled = enabled;
    settings.encodeBool("detailsBlockEnabled", detailsBlockEnabled);
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

  @action
  Future<String> addUser(String user) async {
    try {
      var submitUsers = <String>[];
      blockUserList.forEach((e) => submitUsers.add(e));
      submitUsers.add(user);
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(submitUsers, blockWordList));
      blockUserList = submitUsers;
      return content;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<String> deleteUser(String user) async {
    try {
      var submitUsers = <String>[];
      blockUserList.forEach((e) {
        if (e != user) {
          submitUsers.add(e);
        }
      });
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(submitUsers, blockWordList));
      blockUserList = submitUsers;
      return content;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<String> deleteAllUsers() async {
    try {
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData([], blockWordList));
      blockUserList = [];
      return content;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<String> addWord(String word) async {
    try {
      var submitWords = <String>[];
      blockWordList.forEach((e) => submitWords.add(e));
      submitWords.add(word);
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(blockUserList, submitWords));
      blockWordList = submitWords;
      return content;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<String> deleteWord(String word) async {
    try {
      var submitWords = <String>[];
      blockWordList.forEach((e) {
        if (e != word) {
          submitWords.add(e);
        }
      });
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(blockUserList, submitWords));
      blockWordList = submitWords;
      return content;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<String> deleteAllWords() async {
    try {
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(blockUserList, []));
      blockWordList = [];
      return content;
    } catch (err) {
      rethrow;
    }
  }

  BlockMode getBlockMode() {
    final i =
        settings.decodeInt("blockMode", defaultValue: BlockMode.COLLAPSE.index);
    return getBlockModeByIndex(i);
  }

  @action
  updateBlockMode(BlockMode mode) {
    settings.encodeInt("blockMode", mode.index);
    blockMode = mode;
  }

  BlockMode getBlockModeByIndex(int index) {
    switch (index) {
      case 0:
        return BlockMode.COLLAPSE;
      case 1:
        return BlockMode.PAINT;
      case 2:
        return BlockMode.ALPHA;
      case 3:
        return BlockMode.DELETE_LINE;
      case 4:
        return BlockMode.GONE;
      default:
        return BlockMode.COLLAPSE;
    }
  }
}
