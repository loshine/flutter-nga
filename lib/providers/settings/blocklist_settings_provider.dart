import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/block.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';

enum BlockMode { COLLAPSE, PAINT, ALPHA, DELETE_LINE, GONE }

extension BlockModeExtension on BlockMode {
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

class BlocklistSettingsState {
  final bool clientBlockEnabled;
  final bool listBlockEnabled;
  final bool detailsBlockEnabled;
  final BlockMode blockMode;
  final List<String> blockUserList;
  final List<String> blockWordList;

  const BlocklistSettingsState({
    this.clientBlockEnabled = false,
    this.listBlockEnabled = true,
    this.detailsBlockEnabled = true,
    this.blockMode = BlockMode.COLLAPSE,
    this.blockUserList = const [],
    this.blockWordList = const [],
  });

  BlocklistSettingsState copyWith({
    bool? clientBlockEnabled,
    bool? listBlockEnabled,
    bool? detailsBlockEnabled,
    BlockMode? blockMode,
    List<String>? blockUserList,
    List<String>? blockWordList,
  }) {
    return BlocklistSettingsState(
      clientBlockEnabled: clientBlockEnabled ?? this.clientBlockEnabled,
      listBlockEnabled: listBlockEnabled ?? this.listBlockEnabled,
      detailsBlockEnabled: detailsBlockEnabled ?? this.detailsBlockEnabled,
      blockMode: blockMode ?? this.blockMode,
      blockUserList: blockUserList ?? this.blockUserList,
      blockWordList: blockWordList ?? this.blockWordList,
    );
  }
}

class BlocklistSettingsNotifier extends Notifier<BlocklistSettingsState> {
  static const String _prefsName = 'blocklist';
  SharedPreferences? _prefs;
  Timer? _syncTimer;

  @override
  BlocklistSettingsState build() {
    ref.onDispose(() {
      _syncTimer?.cancel();
    });
    return const BlocklistSettingsState();
  }

  Future<SharedPreferences> get _settings async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    final settings = await _settings;
    final clientBlockEnabled =
        settings.getBool('${_prefsName}_clientBlockEnabled') ?? false;
    final listBlockEnabled =
        settings.getBool('${_prefsName}_listBlockEnabled') ?? true;
    final detailsBlockEnabled =
        settings.getBool('${_prefsName}_detailsBlockEnabled') ?? true;
    final blockModeIndex =
        settings.getInt('${_prefsName}_blockMode') ?? BlockMode.COLLAPSE.index;

    state = state.copyWith(
      clientBlockEnabled: clientBlockEnabled,
      listBlockEnabled: listBlockEnabled,
      detailsBlockEnabled: detailsBlockEnabled,
      blockMode: _getBlockModeByIndex(blockModeIndex),
    );
  }

  void loopSyncBlockList() {
    Future.delayed(Duration(), () async {
      debugPrint('定时任务');
      if (await Data().userRepository.getDefaultUser() != null) {
        await load();
      }
    }).whenComplete(() {
      _syncTimer?.cancel();
      _syncTimer = Timer(Duration(minutes: 5), () => loopSyncBlockList());
    }).catchError((err) {
      debugPrint(err.toString());
    });
  }

  Future<void> setClientBlockEnabled(bool enabled) async {
    state = state.copyWith(clientBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool('${_prefsName}_clientBlockEnabled', enabled);
  }

  Future<void> setListBlockEnabled(bool enabled) async {
    state = state.copyWith(listBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool('${_prefsName}_listBlockEnabled', enabled);
  }

  Future<void> setDetailsBlockEnabled(bool enabled) async {
    state = state.copyWith(detailsBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool('${_prefsName}_detailsBlockEnabled', enabled);
  }

  Future<void> load() async {
    try {
      final blockInfo = await Data().userRepository.getBlockInfo();
      state = state.copyWith(
        blockUserList: blockInfo.blockUserList,
        blockWordList: blockInfo.blockWordList,
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<String> addUser(String user) async {
    try {
      var submitUsers = <String>[...state.blockUserList, user];
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(submitUsers, state.blockWordList));
      state = state.copyWith(blockUserList: submitUsers);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<String> deleteUser(String user) async {
    try {
      var submitUsers =
          state.blockUserList.where((e) => e != user).toList();
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(submitUsers, state.blockWordList));
      state = state.copyWith(blockUserList: submitUsers);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<String> deleteAllUsers() async {
    try {
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData([], state.blockWordList));
      state = state.copyWith(blockUserList: []);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<String> addWord(String word) async {
    try {
      var submitWords = <String>[...state.blockWordList, word];
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(state.blockUserList, submitWords));
      state = state.copyWith(blockWordList: submitWords);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<String> deleteWord(String word) async {
    try {
      var submitWords =
          state.blockWordList.where((e) => e != word).toList();
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(state.blockUserList, submitWords));
      state = state.copyWith(blockWordList: submitWords);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<String> deleteAllWords() async {
    try {
      final content = await Data()
          .userRepository
          .setBlockInfo(BlockInfoData(state.blockUserList, []));
      state = state.copyWith(blockWordList: []);
      return content;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> updateBlockMode(BlockMode mode) async {
    final settings = await _settings;
    await settings.setInt('${_prefsName}_blockMode', mode.index);
    state = state.copyWith(blockMode: mode);
  }

  BlockMode _getBlockModeByIndex(int index) {
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

final blocklistSettingsProvider =
    NotifierProvider<BlocklistSettingsNotifier, BlocklistSettingsState>(
        BlocklistSettingsNotifier.new);

/// 屏蔽判定结果：组合开关、屏蔽模式与匹配规则，UI 只按返回的 [BlockMode] 渲染
class BlockFilter {
  BlockFilter({
    required this.mode,
    required this.listEnabled,
    required this.detailsEnabled,
    required this.matcher,
  });

  factory BlockFilter.fromSettings(BlocklistSettingsState state) {
    final matcher = BlockMatcher(
      users: state.blockUserList,
      words: state.blockWordList,
    );
    return BlockFilter(
      mode: state.blockMode,
      listEnabled: state.clientBlockEnabled && state.listBlockEnabled,
      detailsEnabled: state.clientBlockEnabled && state.detailsBlockEnabled,
      matcher: matcher,
    );
  }

  final BlockMode mode;
  final bool listEnabled;
  final bool detailsEnabled;
  final BlockMatcher matcher;

  /// 主题被屏蔽时返回展示模式，否则返回 null
  BlockMode? topicMode(Topic topic) {
    if (!listEnabled || matcher.isEmpty) return null;
    return matcher.matchesTopic(topic) ? mode : null;
  }

  /// 楼层被屏蔽时返回展示模式，否则返回 null
  BlockMode? replyMode(Reply reply, {String? username}) {
    if (!detailsEnabled || matcher.isEmpty) return null;
    return matcher.matchesReply(reply, username: username) ? mode : null;
  }

  /// 隐藏模式下直接移除被屏蔽的主题，避免列表中残留零高度条目
  List<Topic> visibleTopics(List<Topic> topics) {
    if (mode != BlockMode.GONE) return topics;
    return topics.where((topic) => topicMode(topic) == null).toList();
  }
}

final blockFilterProvider = Provider<BlockFilter>((ref) {
  return BlockFilter.fromSettings(ref.watch(blocklistSettingsProvider));
});
